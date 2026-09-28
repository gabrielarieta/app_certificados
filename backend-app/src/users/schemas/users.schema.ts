import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { IUser } from '../interface/users.interface';

@Schema({
  timestamps: true,
})
export class User extends Document implements IUser {
  @Prop()
  name: string;

  @Prop({ unique: [true, 'Duplicate email entered'] })
  email: string;

  @Prop({ select: false })
  password: string;

  @Prop({ default: 0 })
  spaceUsed: number;
}

export const UserSchema = SchemaFactory.createForClass(User);
