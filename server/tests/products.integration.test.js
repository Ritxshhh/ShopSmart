const request = require('supertest');
const path = require('path');
const express = require('express');

const TEST_DB_URL = 'file://' + path.resolve(__dirname, 'test.db');

let app;
let prisma;

beforeAll(async () => {
  const { PrismaClient } = require('@prisma/client');
  const { PrismaLibSql } = require('@prisma/adapter-libsql');
  const { createClient } = require('@libsql/client');

  const libsql = createClient({ url: TEST_DB_URL });
  await libsql.execute(`
    CREATE TABLE IF NOT EXISTS Product (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      price REAL NOT NULL,
      stock INTEGER NOT NULL DEFAULT 0,
      createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);

  const adapter = new PrismaLibSql({ url: TEST_DB_URL });
  prisma = new PrismaClient({ adapter });

  app = express();
  app.use(express.json());
  app.use('/api/products', require('../src/routes/products')(prisma));
});

beforeEach(async () => {
  await prisma.product.deleteMany();
});

afterAll(async () => {
  await prisma.$disconnect();
});

describe('Products API integration', () => {
  it('POST /api/products creates a record', async () => {
    const res = await request(app)
      .post('/api/products')
      .send({ name: 'Test Product', price: 12.5, stock: 3 });
    expect(res.statusCode).toBe(201);
    expect(res.body).toMatchObject({ name: 'Test Product', price: 12.5 });
  });

  it('GET /api/products returns created records', async () => {
    await request(app).post('/api/products').send({ name: 'Alpha', price: 5, stock: 1 });
    await request(app).post('/api/products').send({ name: 'Beta', price: 10, stock: 2 });
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveLength(2);
  });

  it('GET /api/products/:id returns single product', async () => {
    const created = await request(app)
      .post('/api/products')
      .send({ name: 'Solo', price: 7, stock: 1 });
    const res = await request(app).get(`/api/products/${created.body.id}`);
    expect(res.statusCode).toBe(200);
    expect(res.body.name).toBe('Solo');
  });

  it('PUT /api/products/:id updates a product', async () => {
    const created = await request(app)
      .post('/api/products')
      .send({ name: 'Old Name', price: 1, stock: 1 });
    const res = await request(app)
      .put(`/api/products/${created.body.id}`)
      .send({ name: 'New Name' });
    expect(res.statusCode).toBe(200);
    expect(res.body.name).toBe('New Name');
  });

  it('DELETE /api/products/:id removes the product', async () => {
    const created = await request(app)
      .post('/api/products')
      .send({ name: 'ToDelete', price: 1, stock: 1 });
    const del = await request(app).delete(`/api/products/${created.body.id}`);
    expect(del.statusCode).toBe(200);
    const get = await request(app).get(`/api/products/${created.body.id}`);
    expect(get.statusCode).toBe(404);
  });
});
