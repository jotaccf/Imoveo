#!/bin/bash
# ============================================================
#  IMOVEO — Script de Instalacao Automatica
#  Para Ubuntu Server 22.04 / 24.04 LTS
#  Uso: curl -fsSL https://raw.githubusercontent.com/jotaccf/Imoveo/main/install.sh | bash
# ============================================================

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[IMOVEO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }
ask()   { echo -e "${BLUE}[?]${NC} $1"; }

# ============================================================
#  VERIFICACOES INICIAIS
# ============================================================

if [[ $EUID -eq 0 ]]; then
  error "Nao execute este script como root. Use o seu utilizador normal."
  error "O script usara sudo quando necessario."
  exit 1
fi

# Verificar Ubuntu
if ! grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
  error "Este script requer Ubuntu Server 22.04 ou 24.04 LTS"
  exit 1
fi

log "============================================"
log "  IMOVEO — Instalacao Automatica"
log "  Gestao inteligente do seu patrimonio"
log "============================================"
echo ""

# ============================================================
#  RECOLHER INFORMACOES DO UTILIZADOR
# ============================================================

# Dominio/URL
ask "Qual o dominio para o Imoveo? (ex: imoveo.local)"
read -r DOMAIN
if [[ -z "$DOMAIN" ]]; then
  DOMAIN="imoveo.local"
  warn "A usar dominio por defeito: $DOMAIN"
fi

# Porta da aplicacao
ask "Qual a porta interna para o Imoveo? (ex: 3000) [Enter = 3000]"
read -r APP_PORT
APP_PORT=${APP_PORT:-3000}

# Password PostgreSQL
ask "Escolha uma password para a base de dados PostgreSQL:"
read -rs DB_PASSWORD
echo ""
if [[ -z "$DB_PASSWORD" ]]; then
  DB_PASSWORD=$(openssl rand -base64 16)
  warn "Password gerada automaticamente: $DB_PASSWORD"
fi

# NextAuth Secret
NEXTAUTH_SECRET=$(openssl rand -base64 32)

# Email para notificacoes (opcional)
ask "Email para notificacoes de falha (deixe vazio para saltar):"
read -r ALERT_EMAIL
ALERT_EMAIL=${ALERT_EMAIL:-""}

echo ""
log "Configuracao:"
log "  Dominio:    $DOMAIN"
log "  Porta:      $APP_PORT"
log "  DB Pass:    ********"
log "  Email:      ${ALERT_EMAIL:-'(nenhum)'}"
echo ""
ask "Continuar com a instalacao? (s/n)"
read -r CONFIRM
if [[ "$CONFIRM" != "s" && "$CONFIRM" != "S" && "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  log "Instalacao cancelada."
  exit 0
fi

# ============================================================
#  1. ACTUALIZAR SISTEMA
# ============================================================

log "1/9 — A actualizar o sistema..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq

# ============================================================
#  2. INSTALAR DEPENDENCIAS
# ============================================================

log "2/9 — A instalar dependencias..."
sudo apt-get install -y -qq \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  nginx \
  ufw \
  mailutils \
  msmtp \
  msmtp-mta \
  cron \
  openssl

# ============================================================
#  3. INSTALAR DOCKER
# ============================================================

if command -v docker &>/dev/null; then
  log "3/9 — Docker ja instalado ($(docker --version | awk '{print $3}'))"
else
  log "3/9 — A instalar Docker..."
  curl -fsSL https://get.docker.com | sudo sh
  log "Docker instalado com sucesso"
fi

# ============================================================
#  4. CRIAR UTILIZADOR DEPLOY
# ============================================================

DEPLOY_USER="deploy"
APP_DIR="/opt/imoveo"
BACKUP_DIR="/opt/backups/imoveo"

if id "$DEPLOY_USER" &>/dev/null; then
  log "4/9 — Utilizador '$DEPLOY_USER' ja existe"
else
  log "4/9 — A criar utilizador '$DEPLOY_USER'..."
  sudo useradd -m -s /bin/bash "$DEPLOY_USER"
fi

# Adicionar ao grupo docker
sudo usermod -aG docker "$DEPLOY_USER"

# Criar directorios
sudo mkdir -p "$APP_DIR"
sudo mkdir -p "$BACKUP_DIR"
sudo chown -R "$DEPLOY_USER:$DEPLOY_USER" "$APP_DIR"
sudo chown -R "$DEPLOY_USER:$DEPLOY_USER" "$BACKUP_DIR"

# ============================================================
#  5. CLONAR REPOSITORIO
# ============================================================

log "5/9 — A clonar repositorio..."
if [[ -d "$APP_DIR/.git" ]]; then
  warn "Repositorio ja existe. A actualizar..."
  sudo -u "$DEPLOY_USER" git -C "$APP_DIR" pull origin main
else
  sudo rm -rf "$APP_DIR"
  sudo -u "$DEPLOY_USER" git clone https://github.com/jotaccf/Imoveo.git "$APP_DIR"
fi

# ============================================================
#  6. CONFIGURAR AMBIENTE (.env.prod)
# ============================================================

log "6/9 — A configurar ambiente..."

ENV_FILE="$APP_DIR/.env.prod"
if [[ -f "$ENV_FILE" ]]; then
  warn "Ficheiro .env.prod ja existe. A manter configuracao actual."
else
  sudo -u "$DEPLOY_USER" bash -c "cat > $ENV_FILE << ENVEOF
DATABASE_URL=postgresql://imoveo:${DB_PASSWORD}@postgres:5432/imoveo
POSTGRES_PASSWORD=${DB_PASSWORD}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
NEXTAUTH_URL=http://${DOMAIN}
NODE_ENV=production
UPLOAD_DIR=/app/uploads
MAX_FILE_SIZE=10485760
ENVEOF"
  sudo chmod 600 "$ENV_FILE"
  log "Ficheiro .env.prod criado"
fi

# ============================================================
#  7. CONFIGURAR NGINX
# ============================================================

log "7/9 — A configurar Nginx..."

# Remover site por defeito
sudo rm -f /etc/nginx/sites-enabled/default

# Criar configuracao para Imoveo
sudo bash -c "cat > /etc/nginx/sites-available/imoveo << 'NGINXEOF'
server {
    listen 80;
    server_name ${DOMAIN};

    client_max_body_size 20M;

    gzip on;
    gzip_types text/plain application/json application/javascript text/css;

    location / {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /api/health {
        proxy_pass http://127.0.0.1:${APP_PORT};
        access_log off;
    }
}
NGINXEOF"

# Activar site
sudo ln -sf /etc/nginx/sites-available/imoveo /etc/nginx/sites-enabled/imoveo

# Testar configuracao
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

log "Nginx configurado: ${DOMAIN} -> localhost:${APP_PORT}"

# ============================================================
#  8. CONFIGURAR FIREWALL (UFW)
# ============================================================

log "8/9 — A configurar firewall..."

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "y" | sudo ufw enable

log "Firewall activo (SSH + HTTP + HTTPS)"

# ============================================================
#  9. CONFIGURAR DOCKER LOG ROTATION
# ============================================================

sudo bash -c 'cat > /etc/docker/daemon.json << DOCKEREOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
DOCKEREOF'

sudo systemctl restart docker

# ============================================================
#  10. ARRANCAR APLICACAO
# ============================================================

log "9/9 — A arrancar a aplicacao..."

cd "$APP_DIR"

# Build e arranque
sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# Aguardar arranque
log "A aguardar arranque dos servicos (60s)..."
sleep 60

# Executar migrations
log "A executar migrations..."
sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy || warn "Migrations falharam — pode ser a primeira vez"

# Executar seed
log "A inserir dados iniciais..."
sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml exec -T app npx prisma db seed || warn "Seed falhou — dados podem ja existir"

# ============================================================
#  11. CONFIGURAR BACKUP DIARIO
# ============================================================

log "A configurar backups diarios..."

BACKUP_SCRIPT="$APP_DIR/backup.sh"
sudo -u "$DEPLOY_USER" bash -c "cat > $BACKUP_SCRIPT << 'BACKUPEOF'
#!/bin/bash
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/opt/backups/imoveo
mkdir -p \$BACKUP_DIR

# Backup da base de dados
docker compose -f /opt/imoveo/docker-compose.prod.yml exec -T postgres \
  pg_dump -U imoveo imoveo > \$BACKUP_DIR/imoveo_\$DATE.sql

# Comprimir
gzip \$BACKUP_DIR/imoveo_\$DATE.sql

# Manter apenas os ultimos 30 backups
ls -t \$BACKUP_DIR/*.sql.gz 2>/dev/null | tail -n +31 | xargs -r rm

echo \"\$(date): Backup concluido: imoveo_\$DATE.sql.gz\"
BACKUPEOF"

sudo chmod +x "$BACKUP_SCRIPT"

# Agendar backup diario as 02:00
(sudo -u "$DEPLOY_USER" crontab -l 2>/dev/null | grep -v "backup.sh"; echo "0 2 * * * $BACKUP_SCRIPT >> /opt/backups/imoveo/backup.log 2>&1") | sudo -u "$DEPLOY_USER" crontab -

log "Backups diarios configurados as 02:00"
log "Localizacao: /opt/backups/imoveo/"
log "Retencao: ultimos 30 dias"

# ============================================================
#  12. CONFIGURAR MONITORAMENTO
# ============================================================

# Script de health check
HEALTH_SCRIPT="$APP_DIR/healthcheck.sh"
sudo -u "$DEPLOY_USER" bash -c "cat > $HEALTH_SCRIPT << HEALTHEOF
#!/bin/bash
RESPONSE=\\\$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${APP_PORT}/api/health 2>/dev/null)
if [[ \\\"\\\$RESPONSE\\\" != \\\"200\\\" ]]; then
  echo \\\"\\\$(date): ALERTA — Imoveo nao responde (HTTP \\\$RESPONSE)\\\" >> /opt/backups/imoveo/health.log
  # Tentar reiniciar
  cd /opt/imoveo && docker compose -f docker-compose.prod.yml --env-file .env.prod restart app
  echo \\\"\\\$(date): Servico reiniciado automaticamente\\\" >> /opt/backups/imoveo/health.log
fi
HEALTHEOF"

sudo chmod +x "$HEALTH_SCRIPT"

# Verificar saude a cada 5 minutos
(sudo -u "$DEPLOY_USER" crontab -l 2>/dev/null | grep -v "healthcheck.sh"; echo "*/5 * * * * $HEALTH_SCRIPT") | sudo -u "$DEPLOY_USER" crontab -

# ============================================================
#  RESUMO FINAL
# ============================================================

echo ""
echo ""
log "============================================"
log "  IMOVEO — Instalacao Concluida!"
log "============================================"
echo ""
log "  URL:        http://${DOMAIN}"
log "  Porta:      ${APP_PORT}"
log "  Directorio: ${APP_DIR}"
log "  Backups:    ${BACKUP_DIR}/"
log "  Utilizador: ${DEPLOY_USER}"
echo ""
log "  Credenciais:"
log "    Admin:    admin@imoveo.local / Imoveo2024!"
log "    Gestor:   gestor@imoveo.local / Imoveo2024!"
log "    Operador: operador@imoveo.local / Imoveo2024!"
echo ""
warn "  IMPORTANTE: Altere as passwords no primeiro login!"
echo ""
log "  Comandos uteis:"
log "    sudo su - deploy                    # Mudar para utilizador deploy"
log "    cd /opt/imoveo"
log "    docker compose -f docker-compose.prod.yml ps       # Ver estado"
log "    docker compose -f docker-compose.prod.yml logs -f   # Ver logs"
log "    docker compose -f docker-compose.prod.yml restart   # Reiniciar"
echo ""
log "  Para que o dominio '${DOMAIN}' funcione,"
log "  adicione ao DNS local ou ao /etc/hosts do seu PC:"
log "    $(hostname -I | awk '{print $1}')  ${DOMAIN}"
echo ""
log "============================================"
