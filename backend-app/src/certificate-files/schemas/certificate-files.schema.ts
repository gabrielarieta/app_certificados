import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { IsNumber } from 'class-validator';

@Schema({
  timestamps: true,
})
export class CertificateFiles {
  @Prop({ required: true })
  fileName: string;

  @Prop({ required: true })
  data: string;

  @Prop({ required: true })
  mimeType: string;

  @IsNumber()
  @Prop({ required: true })
  size: number;
}

export const CertificatesFilesSchema =
  SchemaFactory.createForClass(CertificateFiles);
