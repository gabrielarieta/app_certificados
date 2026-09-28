import { ICertificateFiles } from '../interfaces/certificate-files.interface';

export class CertificateFile implements ICertificateFiles {
  _id: string;
  fileName: string;
  data: string;
  mimeType: string;
  createdAt: Date;
  updatedAt: Date;
}
