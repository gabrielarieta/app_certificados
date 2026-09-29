import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { UserSchema } from './schemas/users.schema';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { CertificatesSchema } from 'src/certificates/schemas/certificates.schemas';
import { CertificatesFilesSchema } from 'src/certificate-files/schemas/certificate-files.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'User', schema: UserSchema },
      { name: 'Certificates', schema: CertificatesSchema },
      { name: 'CertificateFiles', schema: CertificatesFilesSchema },
    ]),
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
