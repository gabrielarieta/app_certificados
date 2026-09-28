import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { CertificateFiles } from './schemas/certificate-files.schema';
import { CertificateFilesService } from './certificate-files.service';

describe('CertificateFilesService', () => {
  let service: CertificateFilesService;
  const certificateFilesModel = {
    find: jest.fn(),
    findById: jest.fn(),
    findByIdAndDelete: jest.fn(),
  };
  const certificatesModel = {
    find: jest.fn(),
    exists: jest.fn(),
  };

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
});
