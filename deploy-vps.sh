#!/bin/bash
# ============================================================
# SCRIPT DE DEPLOY - Central do Assinante (Backend)
# Execute na VPS via SSH: bash deploy-vps.sh
# ============================================================

set -e

echo "=========================================="
echo "  Deploy - Central do Assinante API"
echo "=========================================="

# 1. Atualizar sistema
echo "[1/8] Atualizando sistema..."
apt update && apt upgrade -y

# 2. Instalar Node.js 24.x
echo "[2/8] Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt install -y nodejs
node --version
npm --version

# 3. Instalar PostgreSQL
echo "[3/8] Instalando PostgreSQL..."
apt install -y postgresql postgresql-contrib
systemctl start postgresql
systemctl enable postgresql

# 4. Criar banco de dados
echo "[4/8] Criando banco de dados..."
sudo -u postgres psql -c "CREATE USER isp_admin WITH PASSWORD 'senha_segura_aqui';"
sudo -u postgres psql -c "CREATE DATABASE isp_portal OWNER isp_admin;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE isp_portal TO isp_admin;"

# 5. Clonar o projeto do GitHub
echo "[5/8] Baixando o projeto..."
cd /opt
git clone https://github.com/edvaldosimplicio/https-github.com-edvaldosimplicio-central-assinante.git central-assinante
cd central-assinante/backend

# 6. Configurar ambiente
echo "[6/8] Configurando variáveis de ambiente..."
cat > .env << 'EOF'
DATABASE_URL="postgresql://isp_admin:senha_segura_aqui@localhost:5432/isp_portal?schema=public"
JWT_SECRET="$(openssl rand -hex 32)"
PORT=3000
NODE_ENV=production
EOF

# 7. Instalar dependências e migrar banco
echo "[7/8] Instalando dependências e migrando banco..."
npm install
npx prisma generate
npx prisma migrate deploy
node prisma/seed.js

# 8. Configurar PM2 (gerenciador de processos)
echo "[8/8] Configurando PM2 para iniciar automaticamente..."
npm install -g pm2
pm2 start src/server.js --name central-assinante-api
pm2 save
pm2 startup systemd -u root --hp /root
systemctl enable pm2-root

echo ""
echo "=========================================="
echo "  DEPLOY CONCLUÍDO!                    "
echo "=========================================="
echo ""
echo "  API rodando em: http://38.250.217.82:3000"
echo "  Health check:   http://38.250.217.82:3000/api/health"
echo ""
echo "  Comandos úteis:"
echo "  - Ver logs: pm2 logs central-assinante-api"
echo "  - Reiniciar: pm2 restart central-assinante-api"
echo "  - Parar: pm2 stop central-assinante-api"
echo ""
