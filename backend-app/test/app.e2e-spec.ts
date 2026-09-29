/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */

import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import type { App } from 'supertest/types';
import { AppController } from './../src/app.controller';
import { AppModule } from './../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .expect({ status: 'ok' });
  });
});

const runDatabaseE2e = process.env.RUN_DB_E2E === '1';

(runDatabaseE2e ? describe : describe.skip)('Certificate CRUD (e2e)', () => {
  let app: INestApplication<App>;
  let token: string;
  let certificateId: string;
  let fileId: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    const email = `phase2-${Date.now()}@example.com`;
    const signup = await request(app.getHttpServer())
      .post('/auth/signup')
      .send({ name: 'Phase 2 User', email, password: 'strong-password' })
      .expect(201);
    token = signup.body.token;
  });

  afterAll(async () => {
    await app?.close();
  });

  it('creates, reads, updates, downloads, removes a file, and deletes a certificate', async () => {
    const created = await request(app.getHttpServer())
      .post('/certificates')
      .set('Authorization', `Bearer ${token}`)
      .field('title', `Phase 2 Certificate ${Date.now()}`)
      .field('description', 'CRUD flow')
      .field('issuedBy', 'Issuer')
      .field('issuedOn', '2026-01-01T00:00:00.000Z')
      .attach('files', Buffer.from('%PDF-1.7\nphase 2 certificate'), {
        filename: 'certificacao.pdf',
        contentType: 'application/pdf',
      })
      .expect(201);

    certificateId = created.body._id;
    const detail = await request(app.getHttpServer())
      .get(`/certificates/${certificateId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    fileId = detail.body.certificateFiles[0]._id;
    expect(detail.body.issuedBy).toBe('Issuer');
    expect(detail.body.certificateFiles[0].fileName).toBe('certificacao.pdf');

    await request(app.getHttpServer())
      .post(`/certificates/${certificateId}/files`)
      .set('Authorization', `Bearer ${token}`)
      .attach('files', Buffer.from('%PDF-1.7\nattached certificate'), {
        filename: 'attached.pdf',
        contentType: 'application/pdf',
      })
      .expect(201);

    await request(app.getHttpServer())
      .patch(`/certificates/${certificateId}`)
      .set('Authorization', `Bearer ${token}`)
      .send({ issuedBy: 'Updated issuer' })
      .expect(200);

    await request(app.getHttpServer())
      .get(`/certificate-files/${fileId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    await request(app.getHttpServer())
      .delete(`/certificate-files/${fileId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    await request(app.getHttpServer())
      .get(`/certificate-files/${fileId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(404);

    await request(app.getHttpServer())
      .delete(`/certificates/${certificateId}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
  }, 30_000);
});
