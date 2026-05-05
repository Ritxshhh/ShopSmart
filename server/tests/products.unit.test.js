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

describe('GET /api/health', () => {
  it('returns 200 with status ok', async () => {
    const res = await request(app).get('/api/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'ok');
  });
});

describe('GET /api/products', () => {
  it('returns list of products', async () => {
    mockPrisma.product.findMany.mockResolvedValue([
      { id: 1, name: 'Widget', price: 9.99, stock: 10 },
    ]);
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0].name).toBe('Widget');
  });

  it('returns 500 on DB error', async () => {
    mockPrisma.product.findMany.mockRejectedValue(new Error('DB error'));
    const res = await request(app).get('/api/products');
    expect(res.statusCode).toBe(500);
  });
});

describe('GET /api/products/:id', () => {
  it('returns a single product', async () => {
    mockPrisma.product.findUnique.mockResolvedValue({
      id: 1,
      name: 'Widget',
      price: 9.99,
      stock: 10,
    });
    const res = await request(app).get('/api/products/1');
    expect(res.statusCode).toBe(200);
    expect(res.body.name).toBe('Widget');
  });

  it('returns 404 when product not found', async () => {
    mockPrisma.product.findUnique.mockResolvedValue(null);
    const res = await request(app).get('/api/products/999');
    expect(res.statusCode).toBe(404);
  });

  it('returns 500 on DB error', async () => {
    mockPrisma.product.findUnique.mockRejectedValue(new Error('DB error'));
    const res = await request(app).get('/api/products/1');
    expect(res.statusCode).toBe(500);
  });
});

describe('POST /api/products', () => {
  it('creates a product and returns 201', async () => {
    const newProduct = { id: 1, name: 'Gadget', price: 19.99, stock: 5 };
    mockPrisma.product.create.mockResolvedValue(newProduct);
    const res = await request(app)
      .post('/api/products')
      .send({ name: 'Gadget', price: 19.99, stock: 5 });
    expect(res.statusCode).toBe(201);
    expect(res.body.name).toBe('Gadget');
  });

  it('returns 400 when name is missing', async () => {
    const res = await request(app).post('/api/products').send({ price: 5.0 });
    expect(res.statusCode).toBe(400);
  });

  it('returns 500 on DB failure', async () => {
    mockPrisma.product.create.mockRejectedValue(new Error('DB error'));
    const res = await request(app).post('/api/products').send({ name: 'Fail', price: 1 });
    expect(res.statusCode).toBe(500);
  });
});

describe('PUT /api/products/:id', () => {
  it('updates a product and returns it', async () => {
    mockPrisma.product.update.mockResolvedValue({ id: 1, name: 'Updated', price: 15, stock: 3 });
    const res = await request(app).put('/api/products/1').send({ name: 'Updated', price: 15 });
    expect(res.statusCode).toBe(200);
    expect(res.body.name).toBe('Updated');
  });

  it('returns 404 when product not found', async () => {
    mockPrisma.product.update.mockRejectedValue(new Error('Not found'));
    const res = await request(app).put('/api/products/999').send({ name: 'X' });
    expect(res.statusCode).toBe(404);
  });
});

describe('DELETE /api/products/:id', () => {
  it('deletes a product and returns message', async () => {
    mockPrisma.product.delete.mockResolvedValue({});
    const res = await request(app).delete('/api/products/1');
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('Product deleted');
  });

  it('returns 404 when product not found', async () => {
    mockPrisma.product.delete.mockRejectedValue(new Error('Not found'));
    const res = await request(app).delete('/api/products/999');
    expect(res.statusCode).toBe(404);
  });
});
