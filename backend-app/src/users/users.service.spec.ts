import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import * as bcrypt from 'bcryptjs';
import { UsersService } from './users.service';
import { User } from './entities/user.entity';

describe('UsersService', () => {
  let service: UsersService;
  let updatedFields: Record<string, unknown>;
  const usersModel = {
    find: jest.fn(),
    findById: jest.fn(),
    findByIdAndUpdate: jest.fn(
      (_id: string, update: Record<string, unknown>) => {
        updatedFields = update;
        return Promise.resolve({});
      },
    ),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    updatedFields = {};
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getModelToken(User.name), useValue: usersModel },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('limits user lists to the authenticated account', async () => {
    usersModel.find.mockResolvedValue([]);

    await service.findAll('user-id');

    expect(usersModel.find).toHaveBeenCalledWith({ _id: 'user-id' });
  });

  it('hashes a new password before updating the user', async () => {
    const currentPasswordHash = await bcrypt.hash('current-password', 10);
    usersModel.findById.mockReturnValue({
      select: jest.fn().mockResolvedValue({ password: currentPasswordHash }),
    });

    await service.updateById('user-id', {
      password: 'new-password',
      currentPassword: 'current-password',
    });

    const password = updatedFields.password;
    expect(password).not.toBe('new-password');
    expect(typeof password).toBe('string');
    expect(await bcrypt.compare('new-password', String(password))).toBe(true);
    expect(updatedFields).not.toHaveProperty('currentPassword');
  });

  it('requires the current password to change a password', async () => {
    await expect(
      service.updateById('user-id', { password: 'new-password' }),
    ).rejects.toMatchObject({ status: 400 });
  });

  it('rejects a wrong current password', async () => {
    const currentPasswordHash = await bcrypt.hash('current-password', 10);
    usersModel.findById.mockReturnValue({
      select: jest.fn().mockResolvedValue({ password: currentPasswordHash }),
    });

    await expect(
      service.updateById('user-id', {
        password: 'new-password',
        currentPassword: 'wrong-password',
      }),
    ).rejects.toMatchObject({ status: 401 });
  });
});
