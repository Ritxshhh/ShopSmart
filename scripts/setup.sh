#!/usr/bin/env bash
set -e

REPO_DIR="$HOME/shopsmart"

echo "==> Cloning or updating repo..."
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull origin main || true
else
  git clone https://github.com/YOUR_USERNAME/shopsmart.git "$REPO_DIR"
fi

echo "==> Installing server dependencies..."
mkdir -p "$REPO_DIR/server"
cd "$REPO_DIR/server"
npm install

echo "==> Running Prisma migrations..."
npx prisma migrate deploy || true

echo "==> Installing client dependencies and building..."
mkdir -p "$REPO_DIR/client"
cd "$REPO_DIR/client"
npm install
npm run build || true

echo "==> Starting server with pm2..."
cd "$REPO_DIR/server"
if pm2 describe server > /dev/null 2>&1; then
  pm2 restart server
else
  pm2 start src/index.js --name server
fi

pm2 save || true

echo "==> Setup complete."
