import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { Throttle, ThrottlerGuard } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { AuthLoginDto } from './dto/login-auth.dto';
import { RegisterAuthDto } from './dto/register-auth.dto';

@Controller('auth')
@UseGuards(ThrottlerGuard)
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('/signup')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  signUp(@Body() signUpDto: RegisterAuthDto): Promise<{ token: string }> {
    return this.authService.signUp(signUpDto);
  }

  @Post('/login')
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  login(@Body() loginDto: AuthLoginDto): Promise<{ token: string }> {
    return this.authService.login(loginDto);
  }
}
