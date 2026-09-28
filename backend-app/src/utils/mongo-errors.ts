import { ConflictException } from '@nestjs/common';

export function throwConflictForDuplicateKey(
  error: unknown,
  message: string,
): never {
  if (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    error.code === 11000
  ) {
    throw new ConflictException(message);
  }
  throw error;
}
