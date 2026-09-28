export function validateEnvironment(
  config: Record<string, unknown>,
): Record<string, unknown> {
  const jwtSecret = config.JWT_SECRET;
  if (typeof jwtSecret !== 'string' || jwtSecret.length < 32) {
    throw new Error('JWT_SECRET must contain at least 32 characters.');
  }

  const mongodbUrl = config.MONGODB_URL;
  if (typeof mongodbUrl !== 'string' || mongodbUrl.trim().length === 0) {
    throw new Error('MONGODB_URL is required.');
  }

  const port = Number(config.PORT ?? config.APP_PORT ?? 3000);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('PORT must be an integer between 1 and 65535.');
  }

  return { ...config, PORT: port };
}
