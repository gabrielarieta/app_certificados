import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CertificatesModule } from './certificates/certificates.module';
import { DatabaseModule } from './database/database.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { CertificateFilesModule } from './certificate-files/certificate-files.module';

@Module({
  imports: [
    AuthModule,
    CertificatesModule,
    DatabaseModule,
    UsersModule,
    CertificateFilesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
