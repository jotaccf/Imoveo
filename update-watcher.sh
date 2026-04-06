#!/bin/bash
# ============================================================
#  IMOVEO — Update Watcher (B+)
#  Corre via cron a cada minuto no HOST (nao no container)
#  Verifica se UPDATE_REQUESTED existe e executa update com
#  pagina de manutencao no Nginx + logs em tempo real
# ============================================================

APP_DIR="/opt/imoveo"
FLAG="$APP_DIR/UPDATE_REQUESTED"
LOG="/opt/backups/imoveo/update.log"
MAINT_LOG="/var/www/maintenance/update.log"
NGINX_MAINT="/etc/nginx/sites-enabled/imoveo-maintenance"
NGINX_CONF="/etc/nginx/sites-enabled/imoveo"

if [ ! -f "$FLAG" ]; then
  exit 0
fi

# Remover flag imediatamente
rm -f "$FLAG"

# Limpar log anterior
> "$LOG"
> "$MAINT_LOG"

# Funcao para copiar log para area servida pelo Nginx
sync_log() {
  cp -f "$LOG" "$MAINT_LOG" 2>/dev/null
}

log_step() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG"
  sync_log
}

# ============================================================
#  1. ACTIVAR MODO MANUTENCAO
# ============================================================
log_step "Modo de manutencao activado"

# Activar config Nginx de manutencao (se existir o ficheiro disponivel)
if [ -f /etc/nginx/sites-available/imoveo-maintenance ]; then
  ln -sf /etc/nginx/sites-available/imoveo-maintenance "$NGINX_MAINT"
  # Remover config normal para evitar conflito
  rm -f "$NGINX_CONF"
  nginx -s reload 2>/dev/null
  log_step "Nginx: pagina de manutencao activa"
fi

# ============================================================
#  2. BACKUP PRE-ACTUALIZACAO
# ============================================================
log_step "A criar backup pre-actualizacao..."
if [ -f "$APP_DIR/backup.sh" ]; then
  bash "$APP_DIR/backup.sh" >> "$LOG" 2>&1
  sync_log
  log_step "Backup concluido"
else
  log_step "AVISO: backup.sh nao encontrado, a saltar backup"
fi

# ============================================================
#  3. PULL DO REPOSITORIO
# ============================================================
log_step "A obter ultima versao do GitHub..."
cd "$APP_DIR" || exit 1

# Preservar .env.prod
cp -f .env.prod /tmp/imoveo_env_backup 2>/dev/null

git pull origin main >> "$LOG" 2>&1
sync_log
log_step "Codigo actualizado"

# Restaurar .env.prod se foi sobrescrito
cp -f /tmp/imoveo_env_backup .env.prod 2>/dev/null

# ============================================================
#  4. REBUILD CONTAINERS
# ============================================================
log_step "A reconstruir containers Docker..."
ENV_FILE="$APP_DIR/.env.prod"
docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" up -d --build >> "$LOG" 2>&1
sync_log
log_step "Containers reconstruidos"

# ============================================================
#  5. AGUARDAR ARRANQUE
# ============================================================
log_step "A aguardar arranque da aplicacao..."
ATTEMPTS=0
MAX_ATTEMPTS=60
APP_UP=false

while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
  ATTEMPTS=$((ATTEMPTS + 1))
  if curl -sf http://localhost:3000/api/health > /dev/null 2>&1; then
    APP_UP=true
    break
  fi
  sleep 3
  if [ $((ATTEMPTS % 5)) -eq 0 ]; then
    log_step "A aguardar... ($ATTEMPTS/$MAX_ATTEMPTS)"
  fi
done

if [ "$APP_UP" = false ]; then
  log_step "ERRO: Aplicacao nao arrancou em 3 minutos"
  # Desactivar manutencao mesmo assim
fi

# ============================================================
#  6. MIGRATIONS
# ============================================================
if [ "$APP_UP" = true ]; then
  log_step "A executar migrations Prisma..."
  DB_URL=$(grep DATABASE_URL "$ENV_FILE" | head -1 | cut -d= -f2-)
  docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" exec -T -e "DATABASE_URL=$DB_URL" app npx prisma migrate deploy >> "$LOG" 2>&1
  sync_log
  log_step "Migrations concluidas"
fi

# ============================================================
#  7. VERIFICAR VERSAO
# ============================================================
NEW_VERSION=$(cat "$APP_DIR/VERSION" 2>/dev/null || echo "desconhecida")
log_step "Versao instalada: v$NEW_VERSION"

# ============================================================
#  8. DESACTIVAR MODO MANUTENCAO
# ============================================================
log_step "A desactivar modo de manutencao..."
rm -f "$NGINX_MAINT"
# Reactivar config normal
if [ -f /etc/nginx/sites-available/imoveo ]; then
  ln -sf /etc/nginx/sites-available/imoveo "$NGINX_CONF"
fi
nginx -s reload 2>/dev/null
sync_log

log_step "Actualizacao concluida com sucesso"
sync_log
