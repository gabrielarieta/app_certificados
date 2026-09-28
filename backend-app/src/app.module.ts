import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { CertificatesModule } from './certificates/certificates.module';
import { DatabaseModule } from './database/database.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { CertificateFilesModule } from './certificate-files/certificate-files.module';
import { validateEnvironment } from './config/env.validation';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, validate: validateEnvironment }),
    AuthModule,
    CertificatesModule,
    DatabaseModule,
    UsersModule,
    CertificateFilesModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
