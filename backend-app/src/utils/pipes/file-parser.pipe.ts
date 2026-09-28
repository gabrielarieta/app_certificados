import {
  HttpStatus,
  ParseFilePipeBuilder,
  PipeTransform,
} from '@nestjs/common';

export function getFileValidator(): PipeTransform {
  return new ParseFilePipeBuilder()
    .addFileTypeValidator({
      fileType: /(jpg|jpeg|png|pdf)$/,
    })
    .addMaxSizeValidator({
      maxSize: 1000 * 1000,
      message: 'File size must be less than 1MB',
    })
    .build({
      errorHttpStatusCode: HttpStatus.UNPROCESSABLE_ENTITY,
    });
}
