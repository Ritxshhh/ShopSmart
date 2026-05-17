# ShopSmart

A full-stack shopping app — React frontend, Node/Express backend, SQLite3 + Prisma ORM.

---

## Project Architecture

```
shopsmart/
├── client/          # React (Vite) frontend
│   ├── src/
│   │   ├── components/   # ProductCard, CartSummary
│   │   └── __tests__/    # Vitest + RTL component tests
│   └── cypress/          # Cypress E2E tests
├── server/          # Node.js + Express backend
│   ├── src/
│   │   ├── app.js        # Express app + routes
│   │   ├── index.js      # Server entry point
│   │   └── routes/
│   │       └── products.js  # Full CRUD REST API
│   ├── prisma/
│   │   └── schema.prisma    # SQLite DB schema (Product model)
│   └── tests/
│       ├── products.unit.test.js        # Jest unit tests (mocked Prisma)
│       └── products.integration.test.js # Supertest + real SQLite test DB
└── scripts/
    └── setup.sh     # Idempotent EC2 setup script
```

**Data flow:** React → `/api/*` → Express routes → Prisma ORM → SQLite3 file

---

## REST API

| Method | Endpoint              | Description        |
|--------|-----------------------|--------------------|
| GET    | `/api/health`         | Health check       |
| GET    | `/api/products`       | List all products  |
| GET    | `/api/products/:id`   | Get one product    |
| POST   | `/api/products`       | Create product     |
| PUT    | `/api/products/:id`   | Update product     |
| DELETE | `/api/products/:id`   | Delete product     |

---

## Running Locally

```bash
# Server
cd server
cp .env.example .env          # set DATABASE_URL=file:./dev.db
npm install
npx prisma migrate dev
npm run dev

# Client
cd client
npm install
npm run dev
```

---

## Running Tests

```bash
# Server unit tests (mocked Prisma)
cd server && npm test

# Server integration tests (real SQLite test DB)
cd server && npm run test:integration

# Client component tests (Vitest + RTL)
cd client && npm test

# E2E tests (requires running dev server)
cd client && npm run cypress:run
```

---

## CI/CD

### GitHub Actions Workflows

| File | Trigger | What it does |
|------|---------|--------------|
| `.github/workflows/ci.yml` | push/PR to main | Install → Lint → Test (client + server) |
| `.github/workflows/lint.yml` | PR to main | ESLint only (fast PR gate) |
| `.github/workflows/deploy.yml` | push to main | SSH into EC2, git pull, npm install, pm2 restart |

### Deployment

- **Backend** → AWS EC2 via `deploy.yml` (uses `EC2_HOST`, `EC2_USER`, `EC2_KEY` GitHub Secrets)
- **Frontend** → Vercel (auto-deploy on push to main)
- **Alternative backend** → Render (see `render.yaml`)

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `EC2_HOST` | EC2 public IP or hostname |
| `EC2_USER` | SSH username (e.g. `ubuntu`) |
| `EC2_KEY` | Private SSH key (PEM contents) |

---

## EC2 Setup

Run once on a fresh EC2 instance:

```bash
curl -o setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/shopsmart/main/scripts/setup.sh
bash setup.sh
```

The script is idempotent — safe to re-run.

---

## Design Decisions

- **Prisma over raw SQL** — type-safe queries, easy migrations, works with SQLite in dev and can swap to Postgres in prod
- **Vitest for client** — native Vite integration, no extra config; Jest for server since it's CommonJS
- **Separate unit/integration tests** — unit tests mock Prisma (fast, no DB), integration tests use a real `test.db` (reset before each test)
- **Cypress stubs the API** — E2E tests intercept `/api/health` so they don't need a live backend in CI

---

## Challenges

- Prisma's generated client must be regenerated (`npx prisma generate`) after schema changes — handled in CI with an explicit step
- Vitest (ESM) vs Jest (CJS) — client uses Vitest, server uses Jest to match each project's module system
- CORS — configured with `cors()` middleware; production origins should be restricted via `CORS_ORIGIN` env var
