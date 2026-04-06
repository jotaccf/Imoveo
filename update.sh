#!/bin/bash
# ============================================================
#  IMOVEO — Script de Actualizacao
#  Executado pelo botao "Actualizar" na interface
# ============================================================

LOG="/opt/backups/imoveo/update.log"
APP_DIR="/opt/imoveo"
ENV_FILE="$APP_DIR/.env.prod"

echo "$(date): Inicio da actualizacao" >> "$LOG"

cd "$APP_DIR" || exit 1

# 1. Backup antes de actualizar
echo "$(date): A criar backup pre-actualizacao..." >> "$LOG"
bash "$APP_DIR/backup.sh" >> "$LOG" 2>&1

# 2. Pull do repositorio
echo "$(date): A obter ultima versao..." >> "$LOG"
git pull origin main >> "$LOG" 2>&1

# 3. Rebuild containers
echo "$(date): A reconstruir containers..." >> "$LOG"
docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" up -d --build >> "$LOG" 2>&1

# 4. Aguardar arranque
echo "$(date): A aguardar arranque (30s)..." >> "$LOG"
sleep 30

# 5. Migrations
DB_URL=$(grep DATABASE_URL "$ENV_FILE" | head -1 | cut -d= -f2-)
echo "$(date): A executar migrations..." >> "$LOG"
docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" exec -T -e "DATABASE_URL=$DB_URL" app npx prisma migrate deploy >> "$LOG" 2>&1

echo "$(date): Actualizacao concluida" >> "$LOG"
