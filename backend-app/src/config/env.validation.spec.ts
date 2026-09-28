import { validateEnvironment } from './env.validation';

describe('validateEnvironment', () => {
  const requiredConfig = {
    JWT_SECRET: 'a-secure-secret-with-at-least-32-characters',
    MONGODB_URL: 'mongodb://localhost:27017/certificates',
  };

  it('requires a JWT secret with at least 32 characters', () => {
    expect(() =>
      validateEnvironment({ ...requiredConfig, JWT_SECRET: 'too-short' }),
    ).toThrow('JWT_SECRET must contain at least 32 characters.');
  });

  it('requires a MongoDB URL and defaults the API port', () => {
    expect(() =>
      validateEnvironment({ JWT_SECRET: requiredConfig.JWT_SECRET }),
    ).toThrow('MONGODB_URL is required.');
    expect(validateEnvironment(requiredConfig).PORT).toBe(3000);
  });

  it('prefers PORT while supporting the legacy APP_PORT variable', () => {
    expect(
      validateEnvironment({ ...requiredConfig, APP_PORT: '3100' }).PORT,
    ).toBe(3100);
    expect(
      validateEnvironment({
        ...requiredConfig,
        APP_PORT: '3100',
        PORT: '3200',
      }).PORT,
    ).toBe(3200);
  });
});
