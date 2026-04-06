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
docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" build --no-cache >> "$LOG" 2>&1
docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" up -d >> "$LOG" 2>&1

# 4. Aguardar arranque
echo "$(date): A aguardar arranque (30s)..." >> "$LOG"
sleep 30

# 5. Migrations
DB_URL=$(grep DATABASE_URL "$ENV_FILE" | head -1 | cut -d= -f2-)
echo "$(date): A executar migrations..." >> "$LOG"
docker compose -f docker-compose.prod.yml --env-file "$ENV_FILE" exec -T -e "DATABASE_URL=$DB_URL" app npx prisma migrate deploy >> "$LOG" 2>&1

# 6. Garantir que infraestrutura do host esta configurada
echo "$(date): A verificar configuracao do host..." >> "$LOG"

# Pagina de manutencao
sudo mkdir -p /var/www/maintenance
sudo cp "$APP_DIR/maintenance.html" /var/www/maintenance/index.html
sudo chown -R $(whoami):$(whoami) /var/www/maintenance

# Update watcher executavel
chmod +x "$APP_DIR/update-watcher.sh"

# Cron do update watcher (adicionar se nao existe)
if ! crontab -l 2>/dev/null | grep -q "update-watcher.sh"; then
  (crontab -l 2>/dev/null; echo "* * * * * $APP_DIR/update-watcher.sh") | crontab -
  echo "$(date): Update watcher adicionado ao cron" >> "$LOG"
fi

# Config Nginx de manutencao (criar se nao existe)
if [ ! -f /etc/nginx/sites-available/imoveo-maintenance ]; then
  APP_PORT=$(grep APP_PORT "$ENV_FILE" | head -1 | cut -d= -f2- || echo "3000")
  DOMAIN=$(grep DOMAIN "$ENV_FILE" | head -1 | cut -d= -f2- || echo "_")
  sudo tee /etc/nginx/sites-available/imoveo-maintenance > /dev/null << MAINTEOF
server {
    listen 80;
    server_name ${DOMAIN};
    root /var/www/maintenance;
    location / { try_files /index.html =503; }
    location /maintenance/update.log {
        alias /var/www/maintenance/update.log;
        add_header Content-Type text/plain;
        add_header Cache-Control "no-cache, no-store";
    }
    location /api/health {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_connect_timeout 2s;
        proxy_read_timeout 2s;
        error_page 502 503 504 = @down;
    }
    location /api/admin/version {
        proxy_pass http://127.0.0.1:${APP_PORT};
        proxy_connect_timeout 2s;
        proxy_read_timeout 2s;
        error_page 502 503 504 = @down;
    }
    location @down { return 503 '{"status":"updating"}'; add_header Content-Type application/json; }
}
MAINTEOF
  echo "$(date): Config Nginx de manutencao criada" >> "$LOG"
fi

echo "$(date): Actualizacao concluida" >> "$LOG"
