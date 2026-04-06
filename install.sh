#!/bin/bash
# ============================================================
#  IMOVEO — Script de Instalacao Automatica (Idempotente)
#  Para Ubuntu Server 22.04 / 24.04 LTS
#
#  Uso:
#    bash <(curl -fsSL https://raw.githubusercontent.com/jotaccf/Imoveo/main/install.sh)
#
#  Seguro para re-executar — salta passos ja concluidos.
# ============================================================

# NAO usar set -e — queremos continuar apos erros nao fatais

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[IMOVEO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error() { echo -e "${RED}[ERRO]${NC} $1"; }
ok()    { echo -e "${GREEN}  ✓${NC} $1"; }
skip()  { echo -e "${YELLOW}  →${NC} $1 (ja configurado)"; }

# Guardar terminal em fd 3 para input interactivo
# Funciona com: bash script.sh, bash <(curl ...), bash -c "$(curl ...)"
if [ -t 0 ]; then
  exec 3<&0
elif [ -e /dev/tty ]; then
  exec 3</dev/tty
else
  error "Este script requer um terminal interactivo."
  exit 1
fi

prompt() {
  printf "${BLUE}[?]${NC} %s " "$1" >&2
  local answer
  read -r answer <&3
  printf '%s' "$answer"
}

prompt_secret() {
  printf "${BLUE}[?]${NC} %s " "$1" >&2
  local answer
  read -rs answer <&3
  printf '\n' >&2
  printf '%s' "$answer"
}

prompt_confirm() {
  printf "${BLUE}[?]${NC} %s (s/n) " "$1" >&2
  local answer
  read -r answer <&3
  [[ "$answer" == "s" || "$answer" == "S" || "$answer" == "y" || "$answer" == "Y" ]]
}

# Variaveis globais
DEPLOY_USER="deploy"
APP_DIR="/opt/imoveo"
BACKUP_DIR="/opt/backups/imoveo"
CONFIG_FILE="/opt/imoveo/.install-config"

# ============================================================
#  VERIFICACOES INICIAIS
# ============================================================

if [[ $EUID -eq 0 ]]; then
  error "Nao execute como root. Use o seu utilizador normal."
  error "O script usara sudo quando necessario."
  exit 1
fi

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
#  RECOLHER CONFIGURACAO (ou ler existente)
# ============================================================

if [[ -f "$CONFIG_FILE" ]]; then
  warn "Configuracao anterior encontrada. A reutilizar."
  source "$CONFIG_FILE"
  log "  Dominio: $DOMAIN | Porta: $APP_PORT"
  echo ""
  if ! prompt_confirm "Manter esta configuracao?"; then
    sudo rm -f "$CONFIG_FILE"
    warn "Configuracao removida. A recolher novos dados."
  fi
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  DOMAIN=$(prompt "Qual o dominio para o Imoveo? [Enter = imoveo.local]")
  DOMAIN=${DOMAIN:-imoveo.local}

  APP_PORT=$(prompt "Qual a porta interna? [Enter = 3000]")
  APP_PORT=${APP_PORT:-3000}

  DB_PASSWORD=$(prompt_secret "Password PostgreSQL [Enter = gerar automaticamente]:")
  if [[ -z "$DB_PASSWORD" ]]; then
    DB_PASSWORD=$(openssl rand -base64 16)
    warn "Password gerada automaticamente"
  fi

  NEXTAUTH_SECRET=$(openssl rand -base64 32)

  ALERT_EMAIL=$(prompt "Email para notificacoes de falha (Enter para saltar):")

  # IP fixo
  CURRENT_IP=$(hostname -I | awk '{print $1}')
  CURRENT_MASK=$(ip -o -f inet addr show | grep "$CURRENT_IP" | awk '{print $4}' | head -1)
  CURRENT_GW=$(ip route | grep default | awk '{print $3}' | head -1)
  STATIC_IP=""

  if prompt_confirm "Configurar IP fixo? (actual: $CURRENT_IP)"; then
    STATIC_IP=$(prompt "Qual o IP fixo? [Enter = $CURRENT_IP]")
    STATIC_IP=${STATIC_IP:-$CURRENT_IP}
    STATIC_MASK=$(prompt "Mascara CIDR (ex: /20)? [Enter = ${CURRENT_MASK#*/}]")
    STATIC_MASK=${STATIC_MASK:-${CURRENT_MASK#*/}}
    STATIC_GW=$(prompt "Gateway? [Enter = $CURRENT_GW]")
    STATIC_GW=${STATIC_GW:-$CURRENT_GW}
  fi

  echo ""
  log "Configuracao:"
  log "  Dominio:    $DOMAIN"
  log "  Porta:      $APP_PORT"
  log "  Email:      ${ALERT_EMAIL:-'(nenhum)'}"
  if [[ -n "$STATIC_IP" ]]; then
    log "  IP fixo:    $STATIC_IP/$STATIC_MASK via $STATIC_GW"
  fi
  echo ""

  if ! prompt_confirm "Continuar com a instalacao?"; then
    log "Instalacao cancelada."
    exit 0
  fi

  # Guardar configuracao para re-execucao
  sudo mkdir -p "$APP_DIR"
  sudo tee "$CONFIG_FILE" > /dev/null << CFGEOF
DOMAIN="$DOMAIN"
STATIC_IP="$STATIC_IP"
STATIC_MASK="${STATIC_MASK:-}"
STATIC_GW="${STATIC_GW:-}"
APP_PORT="$APP_PORT"
DB_PASSWORD="$DB_PASSWORD"
NEXTAUTH_SECRET="$NEXTAUTH_SECRET"
ALERT_EMAIL="$ALERT_EMAIL"
CFGEOF
  sudo chmod 600 "$CONFIG_FILE"
fi

# ============================================================
#  PASSO 1 — ACTUALIZAR SISTEMA
# ============================================================

log "Passo 1 — Actualizar sistema..."
sudo apt-get update -qq && sudo apt-get upgrade -y -qq
ok "Sistema actualizado"

# ============================================================
#  IP FIXO (se configurado)
# ============================================================

if [[ -n "${STATIC_IP:-}" ]]; then
  NETPLAN_FILE="/etc/netplan/01-static.yaml"
  if [[ -f "$NETPLAN_FILE" ]] && grep -q "$STATIC_IP" "$NETPLAN_FILE" 2>/dev/null; then
    skip "IP fixo $STATIC_IP ja configurado"
  else
    log "A configurar IP fixo: $STATIC_IP/$STATIC_MASK..."
    # Detectar interface de rede
    NET_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    NET_IFACE=${NET_IFACE:-eth0}

    sudo tee "$NETPLAN_FILE" > /dev/null << NETPLANEOF
network:
  version: 2
  ethernets:
    ${NET_IFACE}:
      dhcp4: no
      addresses:
        - ${STATIC_IP}/${STATIC_MASK}
      routes:
        - to: default
          via: ${STATIC_GW}
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
NETPLANEOF

    sudo chmod 600 "$NETPLAN_FILE"
    # Remover configuracao DHCP antiga se existir
    sudo rm -f /etc/netplan/50-cloud-init.yaml 2>/dev/null
    sudo netplan apply 2>/dev/null
    ok "IP fixo configurado: $STATIC_IP"
    warn "Se perder a ligacao SSH, reconecte ao IP $STATIC_IP"
  fi
fi

# ============================================================
#  PASSO 2 — INSTALAR DEPENDENCIAS
# ============================================================

log "Passo 2 — Instalar dependencias..."

DEPS="ca-certificates curl gnupg lsb-release git nginx ufw cron openssl"
MISSING=""
for pkg in $DEPS; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    MISSING="$MISSING $pkg"
  fi
done

if [[ -n "$MISSING" ]]; then
  sudo apt-get install -y -qq $MISSING
  ok "Dependencias instaladas:$MISSING"
else
  skip "Todas as dependencias ja instaladas"
fi

# ============================================================
#  PASSO 3 — INSTALAR DOCKER
# ============================================================

log "Passo 3 — Docker..."

if command -v docker &>/dev/null; then
  skip "Docker $(docker --version | awk '{print $3}')"
else
  curl -fsSL https://get.docker.com | sudo sh
  ok "Docker instalado"
fi

# Garantir que docker arranca no boot
sudo systemctl enable docker 2>/dev/null
sudo systemctl start docker 2>/dev/null

# ============================================================
#  PASSO 4 — UTILIZADOR DEPLOY
# ============================================================

log "Passo 4 — Utilizador deploy..."

if id "$DEPLOY_USER" &>/dev/null; then
  skip "Utilizador '$DEPLOY_USER' ja existe"
else
  sudo useradd -m -s /bin/bash "$DEPLOY_USER"
  log "A definir password para o utilizador '$DEPLOY_USER':"
  sudo passwd "$DEPLOY_USER" < /dev/tty 2>/dev/null || sudo passwd "$DEPLOY_USER" <&3 2>/dev/null || {
    warn "Nao foi possivel definir password automaticamente."
    warn "Execute manualmente: sudo passwd deploy"
  }
  # Adicionar ao sudoers para docker
  echo "$DEPLOY_USER ALL=(ALL) NOPASSWD: /usr/bin/docker, /usr/bin/docker-compose" | sudo tee /etc/sudoers.d/deploy > /dev/null
  ok "Utilizador '$DEPLOY_USER' criado"
fi

# Garantir grupo docker
sudo usermod -aG docker "$DEPLOY_USER" 2>/dev/null

# Criar directorios
sudo mkdir -p "$APP_DIR" "$BACKUP_DIR"
sudo chown -R "$DEPLOY_USER:$DEPLOY_USER" "$APP_DIR"
sudo chown -R "$DEPLOY_USER:$DEPLOY_USER" "$BACKUP_DIR"
ok "Directorios prontos"

# ============================================================
#  PASSO 5 — CLONAR REPOSITORIO
# ============================================================

log "Passo 5 — Repositorio..."

if [[ -d "$APP_DIR/.git" ]]; then
  skip "Repositorio ja existe"
  log "  A actualizar..."
  sudo -u "$DEPLOY_USER" git -C "$APP_DIR" pull origin main 2>/dev/null || warn "Pull falhou — pode estar offline"
else
  # Limpar e clonar
  sudo find "$APP_DIR" -mindepth 1 -not -name '.install-config' -not -name '.env.prod' -delete 2>/dev/null
  sudo -u "$DEPLOY_USER" git clone https://github.com/jotaccf/Imoveo.git "$APP_DIR"
  ok "Repositorio clonado"
fi

# ============================================================
#  PASSO 6 — AMBIENTE (.env.prod)
# ============================================================

log "Passo 6 — Ficheiro de ambiente..."

ENV_FILE="$APP_DIR/.env.prod"
if [[ -f "$ENV_FILE" ]]; then
  skip ".env.prod ja existe"
else
  sudo -u "$DEPLOY_USER" tee "$ENV_FILE" > /dev/null << ENVEOF
DATABASE_URL=postgresql://imoveo:${DB_PASSWORD}@postgres:5432/imoveo
POSTGRES_PASSWORD=${DB_PASSWORD}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
NEXTAUTH_URL=http://${DOMAIN}
NODE_ENV=production
APP_PORT=${APP_PORT}
UPLOAD_DIR=/app/uploads
MAX_FILE_SIZE=10485760
ENVEOF
  sudo chmod 600 "$ENV_FILE"
  ok ".env.prod criado"
fi

# ============================================================
#  PASSO 7 — NGINX
# ============================================================

log "Passo 7 — Nginx..."

if [[ -f "/etc/nginx/sites-available/imoveo" ]]; then
  skip "Nginx ja configurado para Imoveo"
else
  sudo rm -f /etc/nginx/sites-enabled/default

  sudo tee /etc/nginx/sites-available/imoveo > /dev/null << NGINXEOF
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

    location /api/health {
        proxy_pass http://127.0.0.1:${APP_PORT};
        access_log off;
    }
}
NGINXEOF

  sudo ln -sf /etc/nginx/sites-available/imoveo /etc/nginx/sites-enabled/imoveo
  ok "Nginx configurado: ${DOMAIN} -> localhost:${APP_PORT}"
fi

sudo nginx -t 2>/dev/null && sudo systemctl restart nginx && sudo systemctl enable nginx
ok "Nginx activo"

# ============================================================
#  PASSO 8 — FIREWALL
# ============================================================

log "Passo 8 — Firewall..."

if sudo ufw status | grep -q "Status: active"; then
  skip "Firewall ja activo"
else
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 80/tcp
  sudo ufw allow 443/tcp
  echo "y" | sudo ufw enable
  ok "Firewall activo (SSH + HTTP + HTTPS)"
fi

# ============================================================
#  DOCKER LOG ROTATION
# ============================================================

if [[ -f "/etc/docker/daemon.json" ]] && grep -q "max-size" /etc/docker/daemon.json 2>/dev/null; then
  skip "Docker log rotation ja configurado"
else
  sudo tee /etc/docker/daemon.json > /dev/null << 'DOCKEREOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
DOCKEREOF
  sudo systemctl restart docker
  ok "Docker log rotation configurado"
fi

# ============================================================
#  PASSO 9 — ARRANCAR APLICACAO
# ============================================================

log "Passo 9 — Arrancar aplicacao..."

cd "$APP_DIR"

# Verificar se ja esta a correr
if sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml ps 2>/dev/null | grep -q "running"; then
  skip "Aplicacao ja esta a correr"
  log "  A reiniciar para aplicar actualizacoes..."
  sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
else
  sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
fi

log "A aguardar arranque dos servicos (60s)..."
sleep 60

# Migrations
log "A executar migrations..."
sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy 2>/dev/null && ok "Migrations executadas" || warn "Migrations — verificar manualmente"

# Seed
log "A inserir dados iniciais..."
sudo -u "$DEPLOY_USER" docker compose -f docker-compose.prod.yml exec -T app npx prisma db seed 2>/dev/null && ok "Seed executado" || warn "Seed — dados podem ja existir"

# ============================================================
#  BACKUP DIARIO
# ============================================================

log "A configurar backups..."

BACKUP_SCRIPT="$APP_DIR/backup.sh"
sudo -u "$DEPLOY_USER" tee "$BACKUP_SCRIPT" > /dev/null << 'BACKUPEOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=/opt/backups/imoveo
mkdir -p $BACKUP_DIR
docker compose -f /opt/imoveo/docker-compose.prod.yml exec -T postgres \
  pg_dump -U imoveo imoveo > $BACKUP_DIR/imoveo_$DATE.sql
gzip $BACKUP_DIR/imoveo_$DATE.sql
ls -t $BACKUP_DIR/*.sql.gz 2>/dev/null | tail -n +31 | xargs -r rm
echo "$(date): Backup concluido: imoveo_$DATE.sql.gz"
BACKUPEOF
sudo chmod +x "$BACKUP_SCRIPT"

# Crontab — adicionar se nao existe
if sudo -u "$DEPLOY_USER" crontab -l 2>/dev/null | grep -q "backup.sh"; then
  skip "Backup diario ja agendado"
else
  (sudo -u "$DEPLOY_USER" crontab -l 2>/dev/null; echo "0 2 * * * $BACKUP_SCRIPT >> /opt/backups/imoveo/backup.log 2>&1") | sudo -u "$DEPLOY_USER" crontab -
  ok "Backup diario agendado (02:00)"
fi

# ============================================================
#  HEALTH CHECK
# ============================================================

log "A configurar monitoramento..."

HEALTH_SCRIPT="$APP_DIR/healthcheck.sh"
sudo -u "$DEPLOY_USER" tee "$HEALTH_SCRIPT" > /dev/null << HEALTHEOF
#!/bin/bash
RESPONSE=\$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:${APP_PORT}/api/health 2>/dev/null)
if [[ "\$RESPONSE" != "200" ]]; then
  echo "\$(date): ALERTA — Imoveo nao responde (HTTP \$RESPONSE)" >> /opt/backups/imoveo/health.log
  cd /opt/imoveo && docker compose -f docker-compose.prod.yml --env-file .env.prod restart app
  echo "\$(date): Servico reiniciado automaticamente" >> /opt/backups/imoveo/health.log
fi
HEALTHEOF
sudo chmod +x "$HEALTH_SCRIPT"

if sudo -u "$DEPLOY_USER" crontab -l 2>/dev/null | grep -q "healthcheck.sh"; then
  skip "Health check ja agendado"
else
  (sudo -u "$DEPLOY_USER" crontab -l 2>/dev/null; echo "*/5 * * * * $HEALTH_SCRIPT") | sudo -u "$DEPLOY_USER" crontab -
  ok "Health check agendado (cada 5 min)"
fi

# ============================================================
#  RESUMO FINAL
# ============================================================

SERVER_IP=$(hostname -I | awk '{print $1}')

echo ""
echo ""
log "============================================"
log "  IMOVEO — Instalacao Concluida!"
log "============================================"
echo ""
log "  URL:        http://${DOMAIN}"
log "  IP:         ${SERVER_IP}"
log "  Porta:      ${APP_PORT}"
log "  Directorio: ${APP_DIR}"
log "  Backups:    ${BACKUP_DIR}/"
log "  Utilizador: ${DEPLOY_USER}"
echo ""
log "  Credenciais iniciais:"
log "    Admin:    admin@imoveo.local / Imoveo2024!"
log "    Gestor:   gestor@imoveo.local / Imoveo2024!"
log "    Operador: operador@imoveo.local / Imoveo2024!"
echo ""
warn "  IMPORTANTE: Altere as passwords no primeiro login!"
echo ""
log "  Para aceder, adicione ao ficheiro hosts:"
echo ""
log "  Windows: C:\\Windows\\System32\\drivers\\etc\\hosts"
log "  macOS/Linux: /etc/hosts"
echo ""
log "  Adicionar:"
log "    ${SERVER_IP}  ${DOMAIN}"
echo ""
log "  Depois abra: http://${DOMAIN}"
echo ""
log "  Nota: pode re-executar este script com seguranca"
log "  para actualizar ou corrigir a instalacao."
echo ""
log "============================================"
