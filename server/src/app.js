const express = require('express');
var x=1
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/api/health', (_req, res) => {
  res.json({
    status: 'ok',
    message: 'ShopSmart Backend is running',
    timestamp: new Date().toISOString(),
  });
});

app.init = async (prismaInstance) => {
  let prisma = prismaInstance;
  if (!prisma) {
    const { PrismaClient } = require('@prisma/client');
    const { PrismaLibSql } = require('@prisma/adapter-libsql');
    const dbUrl =
      process.env.DATABASE_URL || 'file://' + require('path').resolve(__dirname, '../dev.db');
    const adapter = new PrismaLibSql({ url: dbUrl });
    prisma = new PrismaClient({ adapter });
  }
  app.use('/api/products', require('./routes/products')(prisma));
  return app;
};

app.get('/', (_req, res) => {
  res.send('ShopSmart Backend Service');
});

module.exports = app;
