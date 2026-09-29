import { IUser } from 'src/users/interface/users.interface';
import { ICertificates } from '../interface/certificates.interface';
import { CertificateFile } from 'src/certificate-files/entities/certificate-file.entity';

export class Certificates implements ICertificates {
  _id: string;
  title: string;
  description: string;
  issuedBy: string;
  issuedOn: Date;
  user: IUser;
  certificateFiles: CertificateFile[];
  createdAt: Date;
  updatedAt: Date;
}
