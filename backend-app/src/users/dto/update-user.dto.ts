import { PartialType } from '@nestjs/mapped-types';
import { IsNotEmpty, IsString, ValidateIf } from 'class-validator';
import { RegisterAuthDto } from 'src/auth/dto/register-auth.dto';

export class UpdateUserDto extends PartialType(RegisterAuthDto) {
  @ValidateIf((user: UpdateUserDto) => user.password !== undefined)
  @IsNotEmpty()
  @IsString()
  currentPassword?: string;
}
