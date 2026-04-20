#!/bin/bash
# ============================================================
#  IMOVEO — CLI de Gestao (Bare Metal)
#  Instalado em /usr/local/bin/imoveo
# ============================================================

set -euo pipefail

APP_DIR="/opt/imoveo"
REPO_DIR="$APP_DIR/repo"
CURRENT_DIR="$APP_DIR/current"
SHARED_DIR="$APP_DIR/shared"
RELEASES_DIR="$APP_DIR/releases"
BACKUP_DIR="/opt/backups/imoveo"
LOG_DIR="$APP_DIR/logs"
ENV_FILE="$SHARED_DIR/.env"
APP_USER="imoveo"
APP_PORT=3000
NGINX_CONF="/etc/nginx/sites-enabled/imoveo"
NGINX_MAINT="/etc/nginx/sites-enabled/imoveo-maintenance"
MAINT_DIR="/var/www/maintenance"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[imoveo]${NC} $1"; }
warn() { echo -e "${YELLOW}[imoveo]${NC} $1"; }
err()  { echo -e "${RED}[imoveo]${NC} $1"; exit 1; }

maintenance_on() {
  if [ -f /etc/nginx/sites-available/imoveo-maintenance ]; then
    sudo ln -sf /etc/nginx/sites-available/imoveo-maintenance "$NGINX_MAINT"
    sudo rm -f "$NGINX_CONF"
    sudo nginx -s reload 2>/dev/null
    log "Modo manutencao activado"
  fi
}

maintenance_off() {
  sudo rm -f "$NGINX_MAINT"
  if [ -f /etc/nginx/sites-available/imoveo ]; then
    sudo ln -sf /etc/nginx/sites-available/imoveo "$NGINX_CONF"
  fi
  sudo nginx -s reload 2>/dev/null
  log "Modo manutencao desactivado"
}

# ---------- Comandos ----------

cmd_start() {
  log "A iniciar Imoveo..."
  sudo -u "$APP_USER" pm2 start "$APP_DIR/ecosystem.config.js"
  sudo -u "$APP_USER" pm2 save
  log "Imoveo iniciado"
}

cmd_stop() {
  log "A parar Imoveo..."
  sudo -u "$APP_USER" pm2 stop imoveo
  log "Imoveo parado"
}

cmd_restart() {
  log "A reiniciar Imoveo..."
  sudo -u "$APP_USER" pm2 restart imoveo
  log "Imoveo reiniciado"
}

cmd_status() {
  echo ""
  echo -e "${CYAN}=== IMOVEO — Estado do Sistema ===${NC}"
  echo ""

  # Versao
  VERSION=$(cat "$CURRENT_DIR/VERSION" 2>/dev/null || echo "desconhecida")
  echo -e "  Versao:       ${GREEN}v$VERSION${NC}"

  # Release actual
  CURRENT_RELEASE=$(readlink -f "$CURRENT_DIR" 2>/dev/null || echo "N/A")
  echo -e "  Release:      $CURRENT_RELEASE"

  # PM2
  echo ""
  echo -e "  ${CYAN}--- Processo (pm2) ---${NC}"
  sudo -u "$APP_USER" pm2 describe imoveo 2>/dev/null | grep -E "status|uptime|memory|restarts" | head -4 || echo "  Nao esta a correr"

  # PostgreSQL
  echo ""
  echo -e "  ${CYAN}--- PostgreSQL ---${NC}"
  if pg_isready -q 2>/dev/null; then
    echo -e "  Estado:       ${GREEN}Activo${NC}"
    DB_SIZE=$(sudo -u postgres psql -tAc "SELECT pg_size_pretty(pg_database_size('imoveo'))" 2>/dev/null || echo "N/A")
    echo -e "  Tamanho DB:   $DB_SIZE"
  else
    echo -e "  Estado:       ${RED}Inactivo${NC}"
  fi

  # Nginx
  echo ""
  echo -e "  ${CYAN}--- Nginx ---${NC}"
  if systemctl is-active --quiet nginx; then
    echo -e "  Estado:       ${GREEN}Activo${NC}"
  else
    echo -e "  Estado:       ${RED}Inactivo${NC}"
  fi

  # Health check
  echo ""
  echo -e "  ${CYAN}--- Health ---${NC}"
  if curl -sf "http://localhost:$APP_PORT/api/health" > /dev/null 2>&1; then
    echo -e "  API:          ${GREEN}OK${NC}"
  else
    echo -e "  API:          ${RED}Sem resposta${NC}"
  fi

  # Disco
  echo ""
  echo -e "  ${CYAN}--- Disco ---${NC}"
  df -h / | tail -1 | awk '{printf "  Utilizado:    %s de %s (%s)\n", $3, $2, $5}'

  # Releases
  RELEASE_COUNT=$(ls -d "$RELEASES_DIR"/*/ 2>/dev/null | wc -l)
  echo -e "  Releases:     $RELEASE_COUNT"

  # Backups
  BACKUP_COUNT=$(ls "$BACKUP_DIR"/*.sql* 2>/dev/null | wc -l || echo 0)
  echo -e "  Backups:      $BACKUP_COUNT"

  echo ""
}

cmd_logs() {
  LINES=${2:-50}
  sudo -u "$APP_USER" pm2 logs imoveo --lines "$LINES"
}

cmd_update() {
  log "A actualizar Imoveo..."
  START_TIME=$(date +%s)

  # Garantir que manutencao e desactivada mesmo se o update falhar
  trap 'maintenance_off' EXIT

  # Garantir safe.directory para ambos os users
  git config --global --add safe.directory "$REPO_DIR" 2>/dev/null || true
  sudo -u "$APP_USER" git config --global --add safe.directory "$REPO_DIR" 2>/dev/null || true

  # 1. Pull
  log "A obter ultima versao..."
  cd "$REPO_DIR"
  PREV_COMMIT=$(git rev-parse HEAD)
  sudo -u "$APP_USER" git pull origin main

  NEW_COMMIT=$(git rev-parse HEAD)
  if [ "$PREV_COMMIT" = "$NEW_COMMIT" ]; then
    log "Nenhuma alteracao. Ja esta na ultima versao."
    # Garantir que manutencao nao ficou presa de execucao anterior
    maintenance_off
    trap - EXIT
    return 0
  fi

  # Activar modo manutencao
  maintenance_on

  # Detectar o que mudou
  CHANGED=$(git diff --name-only "$PREV_COMMIT" "$NEW_COMMIT")
  NEEDS_NPM=false
  NEEDS_PRISMA=false

  if echo "$CHANGED" | grep -q "package"; then
    NEEDS_NPM=true
    log "  Dependencias npm alteradas — npm ci"
  fi
  if echo "$CHANGED" | grep -q "prisma/"; then
    NEEDS_PRISMA=true
    log "  Schema Prisma alterado — migration necessaria"
  fi

  # 2. Instalar dependencias (se necessario)
  sudo -u "$APP_USER" bash -c "
    cd $REPO_DIR
    if [ '$NEEDS_NPM' = true ]; then
      npm ci --loglevel=error
    fi
    npx prisma generate
  "

  # 3. Migrations (se necessario)
  if [ "$NEEDS_PRISMA" = true ]; then
    log "A executar migrations..."
    sudo -u "$APP_USER" bash -c "cd $REPO_DIR && npx prisma migrate deploy"
  fi

  # 4. Build
  log "A compilar..."
  sudo -u "$APP_USER" bash -c "cd $REPO_DIR && npm run build"

  # 5. Criar release
  RELEASE="$RELEASES_DIR/$(date +%s)"
  sudo -u "$APP_USER" bash -c "
    mkdir -p '$RELEASE'
    # Copiar standalone incluindo .next oculto (cp -r com /. copia conteudo incluindo dotfiles)
    cp -a $REPO_DIR/.next/standalone/. '$RELEASE/'
    # Adicionar static ao .next do standalone
    cp -r $REPO_DIR/.next/static '$RELEASE/.next/static'
    cp -r $REPO_DIR/public '$RELEASE/public'
    ln -sfn $SHARED_DIR/.env '$RELEASE/.env'
    ln -sfn $SHARED_DIR/.env '$RELEASE/.env.local'
    mkdir -p $SHARED_DIR/uploads
    ln -sfn $SHARED_DIR/uploads '$RELEASE/uploads'
    cp -f $REPO_DIR/VERSION '$RELEASE/VERSION' 2>/dev/null || true
    # Instalar bcryptjs (nao incluido no standalone)
    cd '$RELEASE' && npm install bcryptjs --no-save 2>/dev/null || true
  "

  # 6. Permissoes para Nginx servir estaticos
  sudo chmod 755 "$APP_DIR" "$RELEASES_DIR" "$RELEASE" "$RELEASE/.next"
  sudo chmod -R 755 "$RELEASE/.next/static" "$RELEASE/public"

  # 7. Activar release
  ln -sfn "$RELEASE" "$CURRENT_DIR" 2>/dev/null || sudo ln -sfn "$RELEASE" "$CURRENT_DIR"
  log "Release activada: $RELEASE"

  # 7. Restart app
  sudo -u "$APP_USER" pm2 restart imoveo

  # 8. Aguardar
  log "A aguardar arranque..."
  for i in $(seq 1 30); do
    if curl -sf "http://localhost:$APP_PORT/api/health" > /dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  if curl -sf "http://localhost:$APP_PORT/api/health" > /dev/null 2>&1; then
    VERSION=$(cat "$RELEASE/VERSION" 2>/dev/null || echo "?")
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log "Actualizado para v$VERSION em ${DURATION}s"
  else
    warn "App nao respondeu ao health check — verificar logs: imoveo logs"
  fi

  # 9. Desactivar modo manutencao (trap EXIT tambem chama, mas explicit e melhor)
  trap - EXIT
  maintenance_off

  # 10. Limpar releases antigas (manter ultimas 5)
  ls -dt "$RELEASES_DIR"/*/ 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true
}

cmd_backup() {
  TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
  FILENAME="imoveo_backup_$TIMESTAMP.sql.gz"
  FILEPATH="$BACKUP_DIR/$FILENAME"

  log "A criar backup..."

  # Extrair credenciais do .env
  DB_URL=$(grep DATABASE_URL "$ENV_FILE" | head -1 | cut -d'"' -f2)
  DB_HOST=$(echo "$DB_URL" | sed -n 's|.*@\(.*\):.*|\1|p')
  DB_PORT=$(echo "$DB_URL" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
  DB_USER=$(echo "$DB_URL" | sed -n 's|.*://\(.*\):.*@.*|\1|p')
  DB_NAME=$(echo "$DB_URL" | sed -n 's|.*/\(.*\)|\1|p')
  DB_PASS=$(echo "$DB_URL" | sed -n 's|.*://.*:\(.*\)@.*|\1|p')

  PGPASSWORD="$DB_PASS" pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" | gzip > "$FILEPATH"

  SIZE=$(du -h "$FILEPATH" | cut -f1)
  log "Backup criado: $FILENAME ($SIZE)"

  # Limpar backups antigos (manter ultimos 30)
  ls -t "$BACKUP_DIR"/imoveo_backup_*.sql.gz 2>/dev/null | tail -n +31 | xargs rm -f 2>/dev/null || true
}

cmd_restore() {
  FILEPATH="$1"

  if [ -z "$FILEPATH" ]; then
    echo ""
    echo "Uso: imoveo restore <ficheiro>"
    echo ""
    echo "Backups disponiveis:"
    ls -lh "$BACKUP_DIR"/imoveo_backup_*.sql* 2>/dev/null | awk '{print "  " $NF " (" $5 ")"}'
    echo ""
    return 1
  fi

  # Resolver path relativo
  if [ ! -f "$FILEPATH" ] && [ -f "$BACKUP_DIR/$FILEPATH" ]; then
    FILEPATH="$BACKUP_DIR/$FILEPATH"
  fi

  if [ ! -f "$FILEPATH" ]; then
    err "Ficheiro nao encontrado: $FILEPATH"
  fi

  echo -e "${YELLOW}ATENCAO: Isto vai substituir TODA a base de dados.${NC}"
  read -p "Tem a certeza? (sim/nao): " CONFIRM
  if [ "$CONFIRM" != "sim" ]; then
    log "Restauro cancelado."
    return 0
  fi

  log "A restaurar backup: $FILEPATH"

  # Extrair credenciais
  DB_URL=$(grep DATABASE_URL "$ENV_FILE" | head -1 | cut -d'"' -f2)
  DB_HOST=$(echo "$DB_URL" | sed -n 's|.*@\(.*\):.*|\1|p')
  DB_PORT=$(echo "$DB_URL" | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
  DB_USER=$(echo "$DB_URL" | sed -n 's|.*://\(.*\):.*@.*|\1|p')
  DB_NAME=$(echo "$DB_URL" | sed -n 's|.*/\(.*\)|\1|p')
  DB_PASS=$(echo "$DB_URL" | sed -n 's|.*://.*:\(.*\)@.*|\1|p')

  # Limpar schema
  PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO public;"

  # Restaurar
  if echo "$FILEPATH" | grep -q "\.gz$"; then
    gunzip -c "$FILEPATH" | PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME"
  else
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" < "$FILEPATH"
  fi

  log "Backup restaurado com sucesso"
  log "A reiniciar aplicacao..."
  cmd_restart
}

cmd_rollback() {
  # Listar releases
  RELEASES=($(ls -dt "$RELEASES_DIR"/*/ 2>/dev/null))

  if [ ${#RELEASES[@]} -lt 2 ]; then
    err "Nao ha release anterior para rollback"
  fi

  CURRENT=$(readlink -f "$CURRENT_DIR")
  PREVIOUS=${RELEASES[1]}

  log "Release actual:   $CURRENT"
  log "Release anterior: $PREVIOUS"

  read -p "Fazer rollback para a release anterior? (sim/nao): " CONFIRM
  if [ "$CONFIRM" != "sim" ]; then
    log "Rollback cancelado."
    return 0
  fi

  ln -sfn "$PREVIOUS" "$CURRENT_DIR"
  sudo -u "$APP_USER" pm2 restart imoveo

  log "Rollback completo"
}

cmd_help() {
  VERSION=$(cat "$CURRENT_DIR/VERSION" 2>/dev/null || echo "?")
  echo ""
  echo -e "${CYAN}IMOVEO v$VERSION — Gestao Bare Metal${NC}"
  echo ""
  echo "  Uso: imoveo <comando>"
  echo ""
  echo "  Comandos:"
  echo "    start       Iniciar aplicacao"
  echo "    stop        Parar aplicacao"
  echo "    restart     Reiniciar aplicacao"
  echo "    status      Estado do sistema (app, DB, nginx, disco)"
  echo "    logs [N]    Ver ultimas N linhas de logs (default: 50)"
  echo "    update      Actualizar para ultima versao"
  echo "    backup      Criar backup da base de dados"
  echo "    restore     Restaurar backup (imoveo restore <ficheiro>)"
  echo "    rollback    Reverter para release anterior"
  echo "    help        Mostrar esta ajuda"
  echo ""
}

# ---------- Router ----------

case "${1:-help}" in
  start)    cmd_start ;;
  stop)     cmd_stop ;;
  restart)  cmd_restart ;;
  status)   cmd_status ;;
  logs)     cmd_logs "$@" ;;
  update)   cmd_update ;;
  backup)   cmd_backup ;;
  restore)  cmd_restore "${2:-}" ;;
  rollback) cmd_rollback ;;
  help|*)   cmd_help ;;
esac
