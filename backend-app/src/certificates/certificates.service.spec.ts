import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { CertificatesService } from './certificates.service';
import { Certificates } from './entities/certificate.entity';
import { CertificateFilesService } from 'src/certificate-files/certificate-files.service';

describe('CertificatesService', () => {
  let service: CertificatesService;
  const certificatesModel = {
    create: jest.fn(),
    find: jest.fn(),
    findOne: jest.fn(),
    findOneAndUpdate: jest.fn(),
    findOneAndDelete: jest.fn(),
  };
  const certificateFilesService = {
    create: jest.fn(),
    removeManyCertificateFiles: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CertificatesService,
        {
          provide: getModelToken(Certificates.name),
          useValue: certificatesModel,
        },
        { provide: CertificateFilesService, useValue: certificateFilesService },
      ],
    }).compile();

    service = module.get<CertificatesService>(CertificatesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('limits certificate lists to the authenticated user', async () => {
    const query = { populate: jest.fn().mockResolvedValue([]) };
    certificatesModel.find.mockReturnValue(query);

    await service.findAll('owner-id');

    expect(certificatesModel.find).toHaveBeenCalledWith({ user: 'owner-id' });
    expect(query.populate).toHaveBeenCalledWith({
      path: 'certificateFiles',
      select: 'fileName mimeType size',
    });
  });

  it('scopes certificate updates to the authenticated user', async () => {
    const update = { title: 'Updated title' };
    certificatesModel.findOneAndUpdate.mockResolvedValue({});

    await service.updateById('certificate-id', update, 'owner-id');

    expect(certificatesModel.findOneAndUpdate).toHaveBeenCalledWith(
      { _id: 'certificate-id', user: 'owner-id' },
      update,
      { new: true, runValidators: true },
    );
  });

  it('returns conflict when a user already has a certificate title', async () => {
    certificatesModel.create.mockRejectedValue({ code: 11000 });
    certificateFilesService.create.mockResolvedValue([{ _id: 'file-id' }]);

    await expect(
      service.create(
        {
          title: 'Duplicate title',
          description: '',
          emitedBy: 'Issuer',
          emitedOn: new Date(),
        } as never,
        [],
        { _id: 'owner-id' } as never,
      ),
    ).rejects.toMatchObject({ status: 409 });
    expect(
      certificateFilesService.removeManyCertificateFiles,
    ).toHaveBeenCalledWith(['file-id']);
  });

  it('scopes certificate deletion to the authenticated user', async () => {
    certificatesModel.findOneAndDelete.mockResolvedValue({
      certificateFiles: [],
    });

    await service.removeById('certificate-id', 'owner-id');

    expect(certificatesModel.findOneAndDelete).toHaveBeenCalledWith({
      _id: 'certificate-id',
      user: 'owner-id',
    });
  });
});
