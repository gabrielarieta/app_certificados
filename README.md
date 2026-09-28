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

Create `backend-app/.env` with the backend settings:

```env
PORT=3000
MONGODB_URL=mongodb://mongodb:27017/certificates
JWT_STRATEGY=jwt
JWT_SECRET=replace-with-a-long-random-secret
JWT_EXPIRES=1d
```

When running the API directly on your machine rather than in Docker, use `mongodb://localhost:27017/certificates` for `MONGODB_URL`.

Create `frontend-app/.env` and set the API URL reachable from the device or emulator:

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

## Tests

Run backend tests from `backend-app/`:

```bash
npm test
npm run test:e2e
npm run test:cov
```

Run Flutter tests from `frontend-app/`:

```bash
flutter test
```