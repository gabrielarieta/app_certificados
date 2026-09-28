import { IUser } from '../interface/users.interface';

export class User implements IUser {
  _id: string;
  name: string;
  email: string;
  password: string;
  spaceUsed: number;
  createdAt: Date;
  updatedAt: Date;
}
