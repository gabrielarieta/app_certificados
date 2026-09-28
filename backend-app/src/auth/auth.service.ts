import { Injectable, UnauthorizedException } from '@nestjs/common';

import * as bcrypt from 'bcryptjs';
import { JwtService } from '@nestjs/jwt';
import { RegisterAuthDto } from './dto/register-auth.dto';
import { AuthLoginDto } from './dto/login-auth.dto';
import { UsersService } from 'src/users/users.service';
import { throwConflictForDuplicateKey } from 'src/utils/mongo-errors';
import { User } from 'src/users/entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private userServices: UsersService,
    private jwtService: JwtService,
  ) {}

  async signUp(signUpDto: RegisterAuthDto): Promise<{ token: string }> {
    const { name, email, password } = signUpDto;

    const hashedPassword = await bcrypt.hash(password, 10);

    let user: User;
    try {
      user = await this.userServices.create({
        name,
        email,
        password: hashedPassword,
        spaceUsed: 0,
      });
    } catch (error) {
      throwConflictForDuplicateKey(error, 'Email is already registered.');
    }

    const token = this.jwtService.sign({ id: user._id });

    return { token };
  }

  async login(loginDto: AuthLoginDto): Promise<{ token: string }> {
    const { email, password } = loginDto;

    const user = await this.userServices.findOne({ email });

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const isPasswordMatched = await bcrypt.compare(password, user.password);

    if (!isPasswordMatched) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const token = this.jwtService.sign({ id: user._id });

    return { token };
  }
}
