import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  UseInterceptors,
  UploadedFiles,
  Req,
} from '@nestjs/common';
import { CertificatesService } from './certificates.service';
import { CreateCertificateDto } from './dto/create-certificate.dto';
import { UpdateCertificateDto } from './dto/update-certificate.dto';
import { JwtAuthGuard } from 'src/utils/jwt/jwt-auth.guard';
import { FilesInterceptor } from '@nestjs/platform-express';
import { getFileValidator } from 'src/utils/pipes/file-parser.pipe';
import { User } from 'src/users/entities/user.entity';

interface AuthenticatedRequest {
  user: User;
}

@Controller('certificates')
@UseGuards(JwtAuthGuard)
export class CertificatesController {
  constructor(private readonly certificatesService: CertificatesService) {}

  @Post()
  @UseInterceptors(
    FilesInterceptor('files', 5, {
      limits: { fileSize: 1_000_000, files: 5 },
    }),
  )
  create(
    @Body() createCertificateDto: CreateCertificateDto,
    @UploadedFiles(getFileValidator()) files,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.certificatesService.create(
      createCertificateDto,
      files,
      req.user,
    );
  }

  @Get()
  findAll(@Req() req: AuthenticatedRequest) {
    return this.certificatesService.findAll(req.user._id);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    return this.certificatesService.findById(id, req.user._id);
  }

  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() updateCertificateDto: UpdateCertificateDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.certificatesService.updateById(
      id,
      updateCertificateDto,
      req.user._id,
    );
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    return this.certificatesService.removeById(id, req.user._id);
  }
}
