#!/bin/bash
cd /opt/central-assinante/backend

# Fix database password
sudo -u postgres psql -c "ALTER USER isp_admin WITH PASSWORD 'central123';"

# Fix .env file
cat > .env << EOF
DATABASE_URL="postgresql://isp_admin:central123@localhost:5432/isp_portal?schema=public"
JWT_SECRET="$(openssl rand -hex 32)"
PORT=3000
NODE_ENV=production
EOF

# Push database schema
npx prisma db push --accept-data-loss

# Seed data
node prisma/seed.js

# Start with PM2
npm install -g pm2
pm2 delete central-assinante-api 2>/dev/null || true
pm2 start src/server.js --name central-assinante-api
pm2 save
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u meganet --hp /home/meganet

echo ""
echo "=========================================="
echo "  DEPLOY CONCLUÍDO!"
echo "=========================================="
echo "API rodando em: http://38.250.217.82:3000"
echo "Health: http://38.250.217.82:3000/api/health"
