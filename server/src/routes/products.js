const express = require('express');

const router = express.Router();

// Factory function — receives the Prisma client instance injected from app.js
module.exports = (prisma) => {
  // GET /api/products — fetch all products
  router.get('/', async (_req, res) => {
    try {
      const products = await prisma.product.findMany();
      res.json(products);
    } catch (err) {
      res.status(500).json({ error: 'Failed to fetch products' });
    }
  });

  // GET /api/products/:id — fetch a single product by ID
  router.get('/:id', async (req, res) => {
    try {
      const product = await prisma.product.findUnique({
        where: { id: Number(req.params.id) },
      });
      if (!product) return res.status(404).json({ error: 'Product not found' });
      res.json(product);
    } catch (err) {
      res.status(500).json({ error: 'Failed to fetch product' });
    }
  });

  // POST /api/products — create a new product (name and price are required)
  router.post('/', async (req, res) => {
    const { name, description, price, stock } = req.body;
    if (!name || price === undefined) {
      return res.status(400).json({ error: 'name and price are required' });
    }
    try {
      const product = await prisma.product.create({
        data: { name, description, price: Number(price), stock: Number(stock) || 0 },
      });
      res.status(201).json(product);
    } catch (err) {
      res.status(500).json({ error: 'Failed to create product' });
    }
  });

  // PUT /api/products/:id — update an existing product by ID
  router.put('/:id', async (req, res) => {
    const { name, description, price, stock } = req.body;
    try {
      const product = await prisma.product.update({
        where: { id: Number(req.params.id) },
        data: {
          name,
          description,
          // Only update numeric fields if they are provided in the request body
          price: price !== undefined ? Number(price) : undefined,
          stock: stock !== undefined ? Number(stock) : undefined,
        },
      });
      res.json(product);
    } catch (err) {
      res.status(404).json({ error: 'Product not found' });
    }
  });

  // DELETE /api/products/:id — remove a product by ID
  router.delete('/:id', async (req, res) => {
    try {
      await prisma.product.delete({ where: { id: Number(req.params.id) } });
      res.json({ message: 'Product deleted' });
    } catch (err) {
      res.status(404).json({ error: 'Product not found' });
    }
  });

  return router;
};
