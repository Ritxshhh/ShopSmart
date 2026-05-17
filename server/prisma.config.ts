import path from 'path';
import { defineConfig } from 'prisma/config';

const dbUrl = process.env.DATABASE_URL || 'file:' + path.join(__dirname, 'dev.db');

export default defineConfig({
  schema: path.join(__dirname, 'prisma/schema.prisma'),
  datasource: {
    url: dbUrl,
  },
});
