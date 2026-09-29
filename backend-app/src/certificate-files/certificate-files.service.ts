import { Injectable } from '@nestjs/common';
import { CertificateFiles } from './schemas/certificate-files.schema';
import mongoose from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { CertificateFile } from './entities/certificate-file.entity';
import { Certificates } from 'src/certificates/entities/certificate.entity';
import { fromBuffer } from 'file-type';
import { User } from 'src/users/entities/user.entity';

const allowedMimeTypes = new Set([
  'application/pdf',
  'image/jpeg',
  'image/png',
]);

export interface UploadedCertificateFile {
  originalname: string;
  mimetype: string;
  buffer: Buffer;
  size: number;
}

@Injectable()
export class CertificateFilesService {
  constructor(
    @InjectModel(CertificateFiles.name)
    private certificateFilesModel: mongoose.Model<CertificateFile>,
    @InjectModel(Certificates.name)
    private certificatesModel: mongoose.Model<Certificates>,
    @InjectModel(User.name)
    private usersModel: mongoose.Model<User>,
  ) {}

  async create(files: UploadedCertificateFile[] = []) {
    const certificateFilesList: CertificateFiles[] = [];
    for (const file of files) {
      const detectedType = await fromBuffer(file.buffer);
      if (!detectedType || !allowedMimeTypes.has(detectedType.mime)) {
        throw new Error(
          'File content does not match an allowed certificate type.',
        );
      }
      certificateFilesList.push({
        fileName: sanitizeFileName(
          Buffer.from(file.originalname, 'latin1').toString('utf8'),
        ),
        mimeType: detectedType.mime,
        data: file.buffer.toString('base64'),
        size: file.size,
      });
    }
    return this.certificateFilesModel.insertMany(certificateFilesList);
  }

  async findAll(userId: string) {
    const certificates = await this.certificatesModel
      .find({ user: userId })
      .select('certificateFiles');
    const fileIds = certificates.flatMap((certificate) =>
      certificate.certificateFiles.map((file) => file._id),
    );

    return await this.certificateFilesModel
      .find({ _id: { $in: fileIds } })
      .select('fileName mimeType size createdAt updatedAt');
  }

  async findOneById(id: string, userId: string) {
    const certificate = await this.certificatesModel.exists({
      user: userId,
      certificateFiles: id,
    });
    if (!certificate) return null;
    return this.certificateFilesModel.findById(id);
  }

  async removeById(id: string, userId: string) {
    const certificate = await this.certificatesModel.exists({
      user: userId,
      certificateFiles: id,
    });
    if (!certificate) return null;
    const deletedFile = await this.certificateFilesModel.findByIdAndDelete(id);
    if (!deletedFile) return null;
    await this.certificatesModel.updateMany(
      { user: userId, certificateFiles: id },
      { $pull: { certificateFiles: id } },
    );
    await this.usersModel.updateOne(
      { _id: userId },
      { $inc: { spaceUsed: -deletedFile.size } },
    );
    return deletedFile;
  }

  async removeManyCertificateFiles(certificateFilesIds: string[]) {
    return await this.certificateFilesModel.deleteMany({
      _id: { $in: certificateFilesIds },
    });
  }

  async getTotalSize(certificateFilesIds: string[]): Promise<number> {
    const files = await this.certificateFilesModel
      .find({ _id: { $in: certificateFilesIds } })
      .select('size');
    return files.reduce((total, file) => total + file.size, 0);
  }
}

function sanitizeFileName(fileName: string): string {
  const baseName = fileName.split(/[\\/]/).pop() ?? 'certificate';
  const sanitized = baseName
    .replace(/[^A-Za-z0-9._-]/g, '_')
    .replace(/\.\./g, '_');
  return sanitized && sanitized !== '.' ? sanitized : 'certificate';
}
