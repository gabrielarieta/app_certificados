import { Test, TestingModule } from '@nestjs/testing';
import { CertificateFilesController } from './certificates-files.controller';
import { CertificateFilesService } from './certificate-files.service';

describe('CertificateFilesController', () => {
  let controller: CertificateFilesController;
  const service = {
    findOneById: jest.fn(),
    removeById: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CertificateFilesController],
      providers: [{ provide: CertificateFilesService, useValue: service }],
    }).compile();

    controller = module.get<CertificateFilesController>(
      CertificateFilesController,
    );
  });

  it('returns 404 when a file is not owned by the requester', async () => {
    service.findOneById.mockResolvedValue(null);

    await expect(
      controller.findOneById('file-id', { user: { _id: 'owner-id' } }),
    ).rejects.toMatchObject({ status: 404 });
  });

  it('returns 404 when deleting a missing or unauthorized file', async () => {
    service.removeById.mockResolvedValue(null);

    await expect(
      controller.removeById('file-id', { user: { _id: 'owner-id' } }),
    ).rejects.toMatchObject({ status: 404 });
  });
});
