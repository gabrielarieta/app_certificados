import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateCertificateDto } from './dto/create-certificate.dto';
import { UpdateCertificateDto } from './dto/update-certificate.dto';
import { InjectModel } from '@nestjs/mongoose';
import { Certificates } from './entities/certificate.entity';
import mongoose from 'mongoose';
import { CertificateFilesService } from 'src/certificate-files/certificate-files.service';
import { CertificateFile } from 'src/certificate-files/entities/certificate-file.entity';
import { User } from 'src/users/entities/user.entity';

@Injectable()
export class CertificatesService {
  constructor(
    @InjectModel(Certificates.name)
    private certificatesModel: mongoose.Model<Certificates>,
    private certificateFilesService: CertificateFilesService,
  ) {}

  async create(
    createCertificateDto: CreateCertificateDto,
    files: any,
    user: User,
  ): Promise<Certificates> {
    const certificateFilesList =
      await this.certificateFilesService.create(files);

    const fileIdList = this.getCertificateFilesIds(certificateFilesList);
    const data = Object.assign(createCertificateDto, {
      user: user._id,
      certificateFiles: fileIdList,
    });

    return await this.certificatesModel.create(data);
  }

  async findAll(userId: string): Promise<Certificates[]> {
    return await this.certificatesModel.find({ user: userId }).populate({
      path: 'certificateFiles',
      select: 'fileName mimeType size',
    });
  }

  async findById(id: string, userId: string): Promise<Certificates> {
    const certificate = await this.certificatesModel.findOne({
      _id: id,
      user: userId,
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
    const certificate = await this.certificatesModel.findOneAndUpdate(
      { _id: id, user: userId },
      updateCertificateDto,
      { new: true, runValidators: true },
    );

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

    await this.certificateFilesService.removeManyCertificateFiles(
      deletedCertificate.certificateFiles.map((element) => {
        return element._id;
      }),
    );

    return deletedCertificate;
  }

  private getCertificateFilesIds(
    certificateFileList: CertificateFile[],
  ): string[] {
    return certificateFileList.map((element) => {
      return element._id;
    });
  }
}
