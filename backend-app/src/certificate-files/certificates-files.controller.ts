import {
  Controller,
  Get,
  Param,
  Delete,
  UseGuards,
  Req,
  NotFoundException,
} from '@nestjs/common';
import { JwtAuthGuard } from 'src/utils/jwt/jwt-auth.guard';
import { CertificateFilesService } from './certificate-files.service';

interface AuthenticatedRequest {
  user: { _id: string };
}

@Controller('certificate-files')
@UseGuards(JwtAuthGuard)
export class CertificateFilesController {
  constructor(
    private readonly certificateFilesService: CertificateFilesService,
  ) {}

  @Get()
  findAll(@Req() req: AuthenticatedRequest) {
    return this.certificateFilesService.findAll(req.user._id);
  }

  @Get(':id')
  async findOneById(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    const file = await this.certificateFilesService.findOneById(
      id,
      req.user._id,
    );
    if (!file) throw new NotFoundException('Certificate file not found.');
    return file;
  }

  @Delete(':id')
  async removeById(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    const file = await this.certificateFilesService.removeById(
      id,
      req.user._id,
    );
    if (!file) throw new NotFoundException('Certificate file not found.');
    return file;
  }
}
