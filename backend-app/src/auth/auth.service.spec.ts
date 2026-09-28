import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';
import { AuthService } from './auth.service';
import { RegisterAuthDto } from './dto/register-auth.dto';
import { UsersService } from 'src/users/users.service';

describe('AuthService', () => {
  let service: AuthService;
  const usersService = {
    create: jest.fn().mockResolvedValue({ _id: 'user-id' }),
  };
  const jwtService = {
    sign: jest.fn().mockReturnValue('token'),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: usersService },
        { provide: JwtService, useValue: jwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('accepts registration without server-managed space usage', async () => {
    const registration = Object.assign(new RegisterAuthDto(), {
      name: 'Test User',
      email: 'test@example.com',
      password: 'secure-password',
    });

    expect(await validate(registration)).toHaveLength(0);
  });

  it('initializes space usage on the server', async () => {
    await service.signUp({
      name: 'Test User',
      email: 'test@example.com',
      password: 'secure-password',
    });

    expect(usersService.create).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'Test User',
        email: 'test@example.com',
        spaceUsed: 0,
      }),
    );
  });

  it('normalizes registration email addresses', async () => {
    const registration = plainToInstance(RegisterAuthDto, {
      name: 'Test User',
      email: '  TEST@EXAMPLE.COM  ',
      password: 'secure-password',
    });

    expect(registration.email).toBe('test@example.com');
    expect(await validate(registration)).toHaveLength(0);
  });

  it('rejects passwords outside the bcrypt byte limit', async () => {
    const registration = plainToInstance(RegisterAuthDto, {
      name: 'Test User',
      email: 'test@example.com',
      password: 'é'.repeat(37),
    });

    expect(await validate(registration)).not.toHaveLength(0);
  });

  it('returns conflict when registration email is already used', async () => {
    usersService.create.mockRejectedValue({ code: 11000 });

    await expect(
      service.signUp({
        name: 'Test User',
        email: 'test@example.com',
        password: 'secure-password',
      }),
    ).rejects.toMatchObject({ status: 409 });
  });
});
