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
    await service.updateById('user-id', { password: 'new-password' });

    const password = updatedFields.password;
    expect(password).not.toBe('new-password');
    expect(typeof password).toBe('string');
    expect(await bcrypt.compare('new-password', String(password))).toBe(true);
  });
});
