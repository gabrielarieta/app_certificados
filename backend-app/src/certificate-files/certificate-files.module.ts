import { Module } from '@nestjs/common';
import { CertificateFilesService } from './certificate-files.service';
import { MongooseModule } from '@nestjs/mongoose';
import { CertificatesFilesSchema } from './schemas/certificate-files.schema';
import { CertificateFilesController } from './certificates-files.controller';
import { CertificatesSchema } from 'src/certificates/schemas/certificates.schemas';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'CertificateFiles', schema: CertificatesFilesSchema },
      { name: 'Certificates', schema: CertificatesSchema },
    ]),
  ],
  controllers: [CertificateFilesController],
  providers: [CertificateFilesService],
  exports: [CertificateFilesService],
})
export class CertificateFilesModule {}
