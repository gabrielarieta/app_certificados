import {
  BadRequestException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';
import mongoose from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name)
    private usersModel: mongoose.Model<User>,
  ) {}

  async create(user: Partial<User>): Promise<User> {
    return await this.usersModel.create(user);
  }

  async findAll(userId: string): Promise<User[]> {
    return await this.usersModel.find({ _id: userId });
  }

  async findById(id: string): Promise<User> {
    const isValidId = mongoose.isValidObjectId(id);

    if (!isValidId) {
      throw new BadRequestException('Please enter correct id.');
    }

    const user = await this.usersModel.findById(id);

    if (!user) {
      throw new NotFoundException('User not found.');
    }

    return user;
  }

  async findOne(user: Partial<User>) {
    return await this.usersModel.findOne(user).select('+password');
  }

  async updateById(id: string, updateUserDto: UpdateUserDto) {
    const { currentPassword, ...update } = updateUserDto;
    if (update.password !== undefined) {
      if (!currentPassword) {
        throw new BadRequestException('Current password is required.');
      }
      const currentUser = await this.usersModel
        .findById(id)
        .select('+password');
      if (!currentUser) {
        throw new NotFoundException('User not found.');
      }
      const passwordMatches = await bcrypt.compare(
        currentPassword,
        currentUser.password,
      );
      if (!passwordMatches) {
        throw new UnauthorizedException('Current password is incorrect.');
      }
      update.password = await bcrypt.hash(update.password, 10);
    }

    return await this.usersModel.findByIdAndUpdate(id, update, {
      new: true,
      runValidators: true,
    });
  }

  async removeById(id: string): Promise<User> {
    const deletedUser = await this.usersModel.findByIdAndDelete(id);

    if (!deletedUser) {
      throw new NotFoundException('User not found.');
    }

    return deletedUser;
  }
}
