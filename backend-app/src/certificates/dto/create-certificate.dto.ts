import type { IUser } from 'src/users/interface/users.interface';
import { ICertificates } from '../interface/certificates.interface';
import { IsDateString, IsEmpty, IsNotEmpty, IsString } from 'class-validator';
import { ICertificateFiles } from 'src/certificate-files/interfaces/certificate-files.interface';

export class CreateCertificateDto implements ICertificates {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  description: string;

  @IsString()
  @IsNotEmpty()
  issuedBy: string;

  @IsDateString()
  @IsNotEmpty()
  issuedOn: Date;

  @IsEmpty()
  certificateFiles: ICertificateFiles[];

  @IsEmpty()
  user: IUser;
}
