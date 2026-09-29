process.env.JWT_SECRET ??= 'local-e2e-secret-that-is-at-least-32-characters';
process.env.MONGODB_URL ??=
  'mongodb://certificates_admin:local-dev-password-change-me@localhost:27017/certificates?authSource=admin';
process.env.JWT_EXPIRES ??= '1d';
