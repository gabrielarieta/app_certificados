import { Module } from '@nestjs/common';
import { CertificateFilesService } from './certificate-files.service';
import { MongooseModule } from '@nestjs/mongoose';
import { CertificatesFilesSchema } from './schemas/certificate-files.schema';
import { CertificateFilesController } from './certificates-files.controller';
import { CertificatesSchema } from 'src/certificates/schemas/certificates.schemas';
import { UserSchema } from 'src/users/schemas/users.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'CertificateFiles', schema: CertificatesFilesSchema },
      { name: 'Certificates', schema: CertificatesSchema },
      { name: 'User', schema: UserSchema },
    ]),
  ],
  controllers: [CertificateFilesController],
  providers: [CertificateFilesService],
  exports: [CertificateFilesService],
})
export class CertificateFilesModule {}
