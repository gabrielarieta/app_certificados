import { Module } from '@nestjs/common';
import { CertificatesService } from './certificates.service';
import { CertificatesController } from './certificates.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { CertificatesSchema } from './schemas/certificates.schemas';
import { CertificateFilesModule } from 'src/certificate-files/certificate-files.module';
import { UserSchema } from 'src/users/schemas/users.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'Certificates', schema: CertificatesSchema },
      { name: 'User', schema: UserSchema },
    ]),
    CertificateFilesModule,
  ],
  controllers: [CertificatesController],
  providers: [CertificatesService],
  exports: [CertificatesService],
})
export class CertificatesModule {}
