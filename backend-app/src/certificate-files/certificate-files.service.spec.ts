import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { CertificateFiles } from './schemas/certificate-files.schema';
import { CertificateFilesService } from './certificate-files.service';
import { User } from 'src/users/entities/user.entity';

describe('CertificateFilesService', () => {
  let service: CertificateFilesService;
  const certificateFilesModel = {
    insertMany: jest.fn(),
    find: jest.fn(),
    findById: jest.fn(),
    findByIdAndDelete: jest.fn(),
    find: jest.fn(),
  };
  const certificatesModel = {
    find: jest.fn(),
    exists: jest.fn(),
    updateMany: jest.fn(),
  };
  const usersModel = { updateOne: jest.fn() };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CertificateFilesService,
        {
          provide: getModelToken(CertificateFiles.name),
          useValue: certificateFilesModel,
        },
        {
          provide: getModelToken('Certificates'),
          useValue: certificatesModel,
        },
        { provide: getModelToken(User.name), useValue: usersModel },
      ],
    }).compile();

    service = module.get<CertificateFilesService>(CertificateFilesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('limits file lookups to the authenticated user', async () => {
    certificatesModel.exists.mockResolvedValue({ _id: 'certificate-id' });
    certificateFilesModel.findById.mockResolvedValue({});

    await service.findOneById('file-id', 'owner-id');

    expect(certificatesModel.exists).toHaveBeenCalledWith({
      user: 'owner-id',
      certificateFiles: 'file-id',
    });
  });

  it('does not return files unlinked from the authenticated user', async () => {
    certificatesModel.exists.mockResolvedValue(null);

    await expect(
      service.findOneById('file-id', 'owner-id'),
    ).resolves.toBeNull();
    expect(certificateFilesModel.findById).not.toHaveBeenCalled();
  });

  it('validates magic bytes and sanitizes uploaded names', async () => {
    certificateFilesModel.insertMany.mockResolvedValue([]);

    await service.create([
      {
        originalname: 'certificação.pdf',
        mimetype: 'text/plain',
        buffer: Buffer.from('%PDF-1.7\ncertificate'),
        size: 19,
      },
    ]);

    expect(certificateFilesModel.insertMany).toHaveBeenCalledWith([
      expect.objectContaining({
        fileName: 'certifica__o.pdf',
        mimeType: 'application/pdf',
      }),
    ]);
  });

  it('rejects content whose magic bytes are not allowed', async () => {
    await expect(
      service.create([
        {
          originalname: 'certificate.pdf',
          mimetype: 'application/pdf',
          buffer: Buffer.from('not a pdf'),
          size: 10,
        },
      ]),
    ).rejects.toThrow('File content does not match');
    expect(certificateFilesModel.insertMany).not.toHaveBeenCalled();
  });

  it('removes the file reference from its certificate', async () => {
    certificatesModel.exists.mockResolvedValue({ _id: 'certificate-id' });
    certificateFilesModel.findByIdAndDelete.mockResolvedValue({
      _id: 'file-id',
      size: 100,
    });

    await service.removeById('file-id', 'owner-id');

    expect(certificatesModel.updateMany).toHaveBeenCalledWith(
      { user: 'owner-id', certificateFiles: 'file-id' },
      { $pull: { certificateFiles: 'file-id' } },
    );
    expect(usersModel.updateOne).toHaveBeenCalledWith(
      { _id: 'owner-id' },
      { $inc: { spaceUsed: -100 } },
    );
  });

  it('returns the total size for a set of files', async () => {
    certificateFilesModel.find.mockReturnValue({
      select: jest.fn().mockResolvedValue([{ size: 100 }, { size: 250 }]),
    });

    await expect(service.getTotalSize(['one', 'two'])).resolves.toBe(350);
  });
});
