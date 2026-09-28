import { Module } from '@nestjs/common';
import { CertificatesService } from './certificates.service';
import { CertificatesController } from './certificates.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { CertificatesSchema } from './schemas/certificates.schemas';
import { CertificateFilesModule } from 'src/certificate-files/certificate-files.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'Certificates', schema: CertificatesSchema },
    ]),
    CertificateFilesModule,
  ],
  controllers: [CertificatesController],
  providers: [CertificatesService],
  exports: [CertificatesService],
})
export class CertificatesModule {}
