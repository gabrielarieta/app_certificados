import { Transform } from 'class-transformer';
import { IsByteLength, IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class RegisterAuthDto {
  @IsNotEmpty()
  @IsString()
  readonly name: string;

  @IsNotEmpty()
  @IsEmail()
  @IsString()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : '',
  )
  readonly email: string;

  @IsNotEmpty()
  @IsString()
  @IsByteLength(8, 72)
  readonly password: string;

  constructor(name = '', email = '', password = '') {
    this.name = name;
    this.email = email;
    this.password = password;
  }
}
