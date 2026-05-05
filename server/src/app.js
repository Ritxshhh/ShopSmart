const express = require('express');
const cors = require('cors');

// Initialise Express application
const app = express();

// Enable CORS for all origins and parse incoming JSON request bodies
app.use(cors());
app.use(express.json());

// Health check endpoint — used by ECS, load balancers, and CI to verify the service is up
app.get('/api/health', (_req, res) => {
  res.json({
    status: 'ok',
    message: 'ShopSmart Backend is running',
    timestamp: new Date().toISOString(),
  });
});

// Async init function — sets up Prisma client and mounts product routes.
// Accepts an optional prismaInstance for dependency injection in tests.
app.init = async (prismaInstance) => {
  let prisma = prismaInstance;
  if (!prisma) {
    // Lazy-load Prisma only when not injected (production path)
    const { PrismaClient } = require('@prisma/client');
    const { PrismaLibSql } = require('@prisma/adapter-libsql');
    const dbUrl =
      process.env.DATABASE_URL || 'file://' + require('path').resolve(__dirname, '../dev.db');
    const adapter = new PrismaLibSql({ url: dbUrl });
    prisma = new PrismaClient({ adapter });
  }
  // Mount CRUD routes for products under /api/products
  app.use('/api/products', require('./routes/products')(prisma));
  return app;
};

// Root route — simple service identifier
app.get('/', (_req, res) => {
  res.send('ShopSmart Backend Service');
});

module.exports = app;
