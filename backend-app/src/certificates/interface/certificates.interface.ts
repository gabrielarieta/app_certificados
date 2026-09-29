import { ICertificateFiles } from 'src/certificate-files/interfaces/certificate-files.interface';
import { IUser } from 'src/users/interface/users.interface';

export interface ICertificates {
  title: string;
  description: string;
  issuedBy: string;
  issuedOn: Date;
  certificateFiles: ICertificateFiles[];
  user: IUser;
}
