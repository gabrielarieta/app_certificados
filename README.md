# Certificate Management

A certificate-management application with a Flutter client, a NestJS REST API, and MongoDB for data storage.

## Project structure

- `frontend-app/`: Flutter application for users to sign in and manage certificates.
- `backend-app/`: NestJS API for authentication, users, certificates, and certificate files.

## Requirements

- Flutter SDK (Dart 3.6 or later)
- Node.js and npm
- Docker Compose for the containerized backend, or MongoDB for running the API locally

## Configuration

For a new setup, copy `backend-app/.env.example` to `backend-app/.env` and set the backend settings. The example contains local-only MongoDB credentials; replace them before exposing the service. For an existing `.env`, add `MONGO_ROOT_USER` and `MONGO_ROOT_PASSWORD`, update `MONGODB_URL` to include those credentials and `authSource=admin`, and rename `APP_PORT` to `PORT`.

```env
PORT=3000
MONGODB_URL=mongodb://certificates_admin:local-dev-password-change-me@localhost:27017/certificates?authSource=admin
CERTIFICATE_STORAGE_QUOTA_BYTES=52428800
JWT_SECRET=replace-with-at-least-32-random-characters
JWT_EXPIRES=1d
CORS_ORIGINS=http://localhost:5000
MONGO_ROOT_USER=certificates_admin
MONGO_ROOT_PASSWORD=local-dev-password-change-me
```

`JWT_SECRET` must be at least 32 characters. Generate a private production value with `openssl rand -base64 48`; never commit it. Rotating the value immediately invalidates all existing access tokens, so deploy the new value and require users to sign in again. `PORT` is the canonical API port, and `certificates` is the database name. The legacy `APP_PORT` remains a fallback when `PORT` is unset; rename it to `PORT` when updating existing `.env` files. Keep MongoDB credentials URL-safe or percent-encode them in `MONGODB_URL`.

Before deploying the email-normalization change to an existing database, set `MONGODB_URL` in the shell and run `mongosh "$MONGODB_URL" --file scripts/normalize-user-emails.js` from `backend-app/`. The script checks for addresses that would collide after trimming and lowercasing, prints them, and aborts without changing any records; resolve those accounts and rerun it before starting the new API.

Before deploying the certificate field rename, back up the database and run `mongosh "$MONGODB_URL" --file scripts/rename-certificate-fields.js` from `backend-app/`. The script renames `emitedBy`/`emitedOn` to `issuedBy`/`issuedOn`; it is idempotent for documents already migrated. `CERTIFICATE_STORAGE_QUOTA_BYTES` defaults to 50 MiB and is enforced when creating or attaching files.

The development Compose stack publishes MongoDB only on `127.0.0.1:27017`, with authentication enabled. When running the API directly on the host, start only MongoDB with `docker compose up -d mongodb`; the example `MONGODB_URL` is configured for this case. The API container overrides it with the Compose service hostname.

Before enabling this Compose configuration on an existing MongoDB volume, back up the database and create the admin user while the old MongoDB instance is still running without authentication. In `mongosh admin`, run:

```javascript
db.createUser({
	user: "certificates_admin",
	pwd: passwordPrompt(),
	roles: [{ role: "root", db: "admin" }],
})
```

Use the same username and password in `MONGO_ROOT_USER`, `MONGO_ROOT_PASSWORD`, and the credentials in `MONGODB_URL`, then restart with the authenticated Compose configuration. Do not reuse the example password outside local development.

Create `frontend-app/.env` and set the API URL reachable from the device or emulator (the file is ignored by Git):

```env
API_URL=http://localhost:3000
```

For an Android emulator, use `http://10.0.2.2:3000` instead of `localhost`. For a physical device, use the host machine's network address.

## Run the backend

From the repository root, start the API and MongoDB in development mode:

```bash
cd backend-app
docker compose up --build
```

The API listens on port `3000`. To run the API outside Docker, start MongoDB separately, install dependencies, then run:

```bash
cd backend-app
npm install
npm run start:dev
```

When running the API locally, use `PORT` and `MONGODB_URL` from `backend-app/.env`; the MongoDB server must have the configured root credentials enabled. `CORS_ORIGINS` is a comma-separated allowlist of browser origins.

Changing a user password through `PATCH /users/:id` now requires both `currentPassword` and `password`; profile updates that do not change the password are unaffected.

For the production Docker stack:

```bash
cd backend-app
docker compose -f docker-compose.prod.yml up --build -d
```

Before deploying the per-user certificate-title index to an existing database, replace the old global title index:

```javascript
db.certificates.dropIndex("title_1")
db.certificates.createIndex({ user: 1, title: 1 }, { unique: true })
```

## Run the frontend

With the API running and `frontend-app/.env` configured:

```bash
cd frontend-app
flutter pub get
flutter run
```

The current certificate file preview uses `dart:io`, `path_provider`, and `open_filex`; supported client platforms for this workflow are Android, iOS, macOS, Windows, and Linux. Flutter Web is not supported for opening certificate files until the file-opening implementation is moved behind a conditional platform abstraction.

## Tests

Run backend checks from `backend-app/`:

```bash
npm run lint:check
npm run build
npm test
npm run test:e2e
npm run test:cov
```

Run Flutter tests from `frontend-app/`:

```bash
flutter test
flutter analyze
```

GitHub Actions runs backend lint, build, unit and e2e tests with MongoDB, plus Flutter analysis and tests on pushes and pull requests.