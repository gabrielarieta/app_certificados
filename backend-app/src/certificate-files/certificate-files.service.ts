/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */

import { Injectable } from '@nestjs/common';
import { CertificateFiles } from './schemas/certificate-files.schema';
import mongoose from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { CertificateFile } from './entities/certificate-file.entity';
import { Certificates } from 'src/certificates/entities/certificate.entity';

@Injectable()
export class CertificateFilesService {
  constructor(
    @InjectModel(CertificateFiles.name)
    private certificateFilesModel: mongoose.Model<CertificateFile>,
    @InjectModel(Certificates.name)
    private certificatesModel: mongoose.Model<Certificates>,
  ) {}

  async create(files) {
    const certificateFilesList: CertificateFiles[] = [];
    files.forEach((element) => {
      certificateFilesList.push({
        fileName: element.originalname,
        mimeType: element.mimetype,
        data: element.buffer.toString('base64'),
        size: element.size,
      });
    });
    return await this.certificateFilesModel.insertMany(certificateFilesList);
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
    if (!certificate) {
      return null;
    }

    return await this.certificateFilesModel.findById(id);
  }

  async removeById(id: string, userId: string) {
    const certificate = await this.certificatesModel.exists({
      user: userId,
      certificateFiles: id,
    });
    if (!certificate) {
      return null;
    }

    return await this.certificateFilesModel.findByIdAndDelete(id);
  }

  async removeManyCertificateFiles(certificateFilesIds: string[]) {
    return await this.certificateFilesModel.deleteMany({
      _id: { $in: certificateFilesIds },
    });
  }
}
