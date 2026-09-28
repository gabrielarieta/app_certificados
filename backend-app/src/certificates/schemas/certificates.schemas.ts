import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { User } from '../../users/schemas/users.schema';
import { CertificateFiles } from 'src/certificate-files/schemas/certificate-files.schema';

@Schema({
  timestamps: true,
})
export class Certificates {
  @Prop({ required: true })
  title: string;

  @Prop()
  description: string;

  @Prop({ required: true })
  emitedBy: string;

  @Prop({ required: true })
  emitedOn: string;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'User', select: false })
  user: User;

  @Prop({ type: [mongoose.Schema.Types.ObjectId], ref: 'CertificateFiles' })
  certificateFiles: CertificateFiles[];
}

export const CertificatesSchema = SchemaFactory.createForClass(Certificates);

CertificatesSchema.index({ user: 1, title: 1 }, { unique: true });
