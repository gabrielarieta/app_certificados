import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateCertificateDto } from './dto/create-certificate.dto';
import { UpdateCertificateDto } from './dto/update-certificate.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Certificates } from './entities/certificate.entity';
import mongoose from 'mongoose';
import {
  CertificateFilesService,
  UploadedCertificateFile,
} from 'src/certificate-files/certificate-files.service';
import { CertificateFile } from 'src/certificate-files/entities/certificate-file.entity';
import { User } from 'src/users/entities/user.entity';
import { throwConflictForDuplicateKey } from 'src/utils/mongo-errors';
import { User as UserSchema } from 'src/users/schemas/users.schema';

const defaultQuotaBytes = 50 * 1024 * 1024;

@Injectable()
export class CertificatesService {
  constructor(
    @InjectModel(Certificates.name)
    private certificatesModel: mongoose.Model<Certificates>,
    @InjectModel(UserSchema.name)
    private usersModel: mongoose.Model<User>,
    private certificateFilesService: CertificateFilesService,
  ) {}

  async create(
    createCertificateDto: CreateCertificateDto,
    files: UploadedCertificateFile[],
    user: User,
  ): Promise<Certificates> {
    const certificateFilesList =
      await this.certificateFilesService.create(files);

    const fileIdList = this.getCertificateFilesIds(certificateFilesList);
    const data = Object.assign({}, createCertificateDto, {
      user: user._id,
      certificateFiles: fileIdList,
    });

    let createdCertificate: Certificates | undefined;
    try {
      createdCertificate = await this.certificatesModel.create(data);
      await this.incrementSpace(
        user._id,
        this.getFilesSize(certificateFilesList),
      );
      return createdCertificate;
    } catch (error) {
      await this.certificateFilesService.removeManyCertificateFiles(fileIdList);
      if (createdCertificate) {
        await this.certificatesModel.deleteOne({ _id: createdCertificate._id });
      }
      throwConflictForDuplicateKey(error, 'Certificate title already exists.');
    }
  }

  async findAll(userId: string): Promise<Certificates[]> {
    return await this.certificatesModel.find({ user: userId }).populate({
      path: 'certificateFiles',
      select: 'fileName mimeType size',
    });
  }

  async findById(id: string, userId: string): Promise<Certificates> {
    const certificate = await this.certificatesModel
      .findOne({
        _id: id,
        user: userId,
      })
      .populate({
        path: 'certificateFiles',
        select: 'fileName mimeType size createdAt updatedAt',
      });

    if (!certificate) {
      throw new NotFoundException('Certificate not found.');
    }

    return certificate;
  }

  async updateById(
    id: string,
    updateCertificateDto: UpdateCertificateDto,
    userId: string,
  ): Promise<Certificates> {
    let certificate: Certificates | null;
    try {
      certificate = await this.certificatesModel.findOneAndUpdate(
        { _id: id, user: userId },
        updateCertificateDto,
        { new: true, runValidators: true },
      );
    } catch (error) {
      throwConflictForDuplicateKey(error, 'Certificate title already exists.');
    }

    if (!certificate) {
      throw new NotFoundException('Certificate not found.');
    }

    return certificate;
  }

  async removeById(id: string, userId: string): Promise<Certificates> {
    const deletedCertificate = await this.certificatesModel.findOneAndDelete({
      _id: id,
      user: userId,
    });
    if (!deletedCertificate) {
      throw new NotFoundException('Certificate not found.');
    }

    const fileIds = deletedCertificate.certificateFiles.map(
      (element) => element._id,
    );
    const fileSize = await this.certificateFilesService.getTotalSize(fileIds);
    await this.certificateFilesService.removeManyCertificateFiles(fileIds);
    await this.incrementSpace(userId, -fileSize);

    return deletedCertificate;
  }

  async appendFiles(
    id: string,
    files: UploadedCertificateFile[],
    userId: string,
  ): Promise<Certificates> {
    const certificate = await this.certificatesModel.findOne({
      _id: id,
      user: userId,
    });
    if (!certificate) throw new NotFoundException('Certificate not found.');

    const createdFiles = await this.certificateFilesService.create(files);
    const fileIds = this.getCertificateFilesIds(createdFiles);
    try {
      const updated = await this.certificatesModel.findOneAndUpdate(
        { _id: id, user: userId },
        { $push: { certificateFiles: { $each: fileIds } } },
        { new: true, runValidators: true },
      );
      if (!updated) throw new NotFoundException('Certificate not found.');
      await this.incrementSpace(userId, this.getFilesSize(createdFiles));
      return updated;
    } catch (error) {
      await this.certificateFilesService.removeManyCertificateFiles(fileIds);
      throw error;
    }
  }

  private getCertificateFilesIds(
    certificateFileList: CertificateFile[],
  ): string[] {
    return certificateFileList.map((element) => {
      return element._id;
    });
  }

  private getFilesSize(files: CertificateFile[]): number {
    return files.reduce((total, file) => total + file.size, 0);
  }

  private async incrementSpace(userId: string, amount: number): Promise<void> {
    if (amount <= 0) {
      await this.usersModel.updateOne(
        { _id: userId },
        { $inc: { spaceUsed: amount } },
      );
      return;
    }
    const quota = Number(
      process.env.CERTIFICATE_STORAGE_QUOTA_BYTES ?? defaultQuotaBytes,
    );
    const user = await this.usersModel.findOneAndUpdate(
      {
        _id: userId,
        $expr: { $lte: [{ $add: ['$spaceUsed', amount] }, quota] },
      },
      { $inc: { spaceUsed: amount } },
      { new: true },
    );
    if (!user) throw new Error('Certificate storage quota exceeded.');
  }
}
