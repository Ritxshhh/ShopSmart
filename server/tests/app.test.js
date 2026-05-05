const request = require('supertest');
const express = require('express');

const mockPrisma = {
  product: {
    findMany: jest.fn(),
    findUnique: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
};

const app = express();
app.use(express.json());
app.get('/api/health', (_req, res) =>
  res.json({
    status: 'ok',
    message: 'ShopSmart Backend is running',
    timestamp: new Date().toISOString(),
  })
);
app.use('/api/products', require('../src/routes/products')(mockPrisma));
app.get('/', (_req, res) => res.send('ShopSmart Backend Service'));

describe('GET /api/health', () => {
  it('should return 200 and status ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('status', 'ok');
  });
});

describe('GET /', () => {
  it('should return 200 with service name', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toEqual(200);
    expect(res.text).toContain('ShopSmart');
  });
});
