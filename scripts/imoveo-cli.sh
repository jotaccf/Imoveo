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

# ---------- Validacao de integridade ----------

# Verifica que o sistema esta em estado blue-green saudavel.
# Retorna 0 se OK, 1 se ha drift.
validate_current() {
  [ -L "$CURRENT_DIR" ] || return 1
  local target
  target=$(readlink -f "$CURRENT_DIR")
  [[ "$target" == "$RELEASES_DIR"/* ]] || return 1
  [ -f "$CURRENT_DIR/server.js" ] || return 1
  [ "$(readlink -f "$CURRENT_DIR/.env" 2>/dev/null)" = "$SHARED_DIR/.env" ] || return 1
  return 0
}

# Detecta daemons pm2 paralelos (a correr fora de $APP_DIR/.pm2)
parallel_pm2_daemons() {
  ps -ef 2>/dev/null | grep "PM2 .* God Daemon" | grep -v grep | grep -v "$APP_DIR/.pm2" || true
}

# Mata daemons pm2 paralelos detectados
kill_parallel_pm2() {
  local found=0
  for daemon_dir in /home/*/.pm2; do
    [ -d "$daemon_dir" ] || continue
    local daemon_user
    daemon_user=$(basename "$(dirname "$daemon_dir")")
    if pgrep -fu "$daemon_user" "PM2.*God Daemon" >/dev/null 2>&1; then
      warn "  Daemon pm2 paralelo (user=$daemon_user) — a eliminar..."
      sudo -u "$daemon_user" pm2 delete all >/dev/null 2>&1 || true
      sudo -u "$daemon_user" pm2 unstartup systemd >/dev/null 2>&1 || true
      sudo -u "$daemon_user" pm2 kill >/dev/null 2>&1 || true
      found=$((found+1))
    fi
  done
  return $found
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

cmd_doctor() {
  local ok=0
  local fail=0

  echo ""
  echo -e "${CYAN}=== IMOVEO Doctor — Diagnostico ===${NC}"
  echo ""

  check_ok()   { echo -e "  ${GREEN}OK${NC}   $1${2:+ — $2}"; ok=$((ok+1)); }
  check_fail() { echo -e "  ${RED}FAIL${NC} $1${2:+ — $2}"; fail=$((fail+1)); }

  # 1. current symlink
  if [ -L "$CURRENT_DIR" ]; then
    local target
    target=$(readlink -f "$CURRENT_DIR")
    if [[ "$target" == "$RELEASES_DIR"/* ]]; then
      check_ok "current symlink" "$target"
    else
      check_fail "current symlink" "aponta para $target (esperado $RELEASES_DIR/...)"
    fi
  else
    check_fail "current symlink" "nao existe ou nao e symlink"
  fi

  # 2. server.js
  if [ -f "$CURRENT_DIR/server.js" ]; then
    local size
    size=$(stat -c '%s' "$CURRENT_DIR/server.js" 2>/dev/null || echo "?")
    check_ok "server.js existe" "$size bytes"
  else
    check_fail "server.js existe" "nao encontrado em $CURRENT_DIR"
  fi

  # 3. .env symlink para shared
  if [ -L "$CURRENT_DIR/.env" ]; then
    local env_target
    env_target=$(readlink -f "$CURRENT_DIR/.env" 2>/dev/null || echo "")
    if [ "$env_target" = "$SHARED_DIR/.env" ]; then
      check_ok ".env → shared"
    else
      check_fail ".env → shared" "aponta para $env_target"
    fi
  else
    check_fail ".env e symlink" "nao e symlink"
  fi

  # 4. Daemons pm2 paralelos
  local parallel_count
  parallel_count=$(parallel_pm2_daemons | grep -c . || true)
  if [ "${parallel_count:-0}" -eq 0 ]; then
    check_ok "pm2 daemons" "apenas $APP_USER"
  else
    check_fail "pm2 daemons" "$parallel_count paralelo(s) detectado(s)"
    parallel_pm2_daemons | sed 's/^/         /'
  fi

  # 5. pm2 status do imoveo
  local pm2_status
  pm2_status=$(sudo -u "$APP_USER" pm2 describe imoveo 2>/dev/null | grep -E "^│ status" | head -1 | awk -F'│' '{print $3}' | tr -d ' ' || echo "")
  if [ "$pm2_status" = "online" ]; then
    check_ok "pm2 status imoveo" "online"
  else
    check_fail "pm2 status imoveo" "status=${pm2_status:-nao registado}"
  fi

  # 6. App responde HTTP
  if curl -sf "http://localhost:$APP_PORT/api/health" > /dev/null 2>&1; then
    check_ok "app HTTP :$APP_PORT" "responde"
  elif curl -sf "http://localhost:$APP_PORT/login" > /dev/null 2>&1; then
    check_ok "app HTTP :$APP_PORT" "responde (sem /api/health)"
  else
    check_fail "app HTTP :$APP_PORT" "sem resposta"
  fi

  # 7. PostgreSQL
  if pg_isready -q 2>/dev/null; then
    check_ok "PostgreSQL" "responde"
  else
    check_fail "PostgreSQL" "nao responde"
  fi

  # 8. Versoes build vs repo
  local build_version
  local repo_version
  build_version=$(cat "$CURRENT_DIR/VERSION" 2>/dev/null || echo "?")
  repo_version=$(cat "$REPO_DIR/VERSION" 2>/dev/null || echo "?")
  if [ "$build_version" = "$repo_version" ]; then
    check_ok "versao build = repo" "v$build_version"
  else
    check_fail "versao build = repo" "build=v$build_version, repo=v$repo_version"
  fi

  # 9. Nginx static path consistente
  local nginx_alias
  nginx_alias=$(grep -oE 'alias[[:space:]]+[^;]+\.next/static' /etc/nginx/sites-enabled/imoveo 2>/dev/null | head -1 | awk '{print $2}' || echo "")
  if [ -d "$nginx_alias" ]; then
    check_ok "nginx static path" "$nginx_alias"
  else
    check_fail "nginx static path" "alias '$nginx_alias' nao resolve"
  fi

  echo ""
  if [ "$fail" -eq 0 ]; then
    echo -e "  ${GREEN}Tudo OK${NC} ($ok checks passaram)"
  else
    echo -e "  ${RED}$fail problema(s) detectado(s)${NC} ($ok OK)"
    echo ""
    echo "  Para reparar: sudo imoveo reconcile"
  fi
  echo ""
}

# Cria nova release a partir do build existente em $REPO_DIR.
# Funcao partilhada entre cmd_update e cmd_reconcile.
_create_release() {
  local RELEASE="$1"

  [ -f "$REPO_DIR/.next/standalone/server.js" ] || err "Build standalone nao existe. Corre 'imoveo update' primeiro."

  # Criar como root para evitar EACCES em ficheiros com owner errado
  mkdir -p "$RELEASE"
  cp -a "$REPO_DIR/.next/standalone/." "$RELEASE/"
  cp -r "$REPO_DIR/.next/static" "$RELEASE/.next/static"
  cp -r "$REPO_DIR/public" "$RELEASE/public"
  rm -f "$RELEASE/.env" "$RELEASE/.env.local"
  chown -R "$APP_USER:$APP_USER" "$RELEASE"

  sudo -u "$APP_USER" bash <<EOF
    set -e
    ln -sfn "$SHARED_DIR/.env" "$RELEASE/.env"
    ln -sfn "$SHARED_DIR/.env" "$RELEASE/.env.local"
    mkdir -p "$SHARED_DIR/uploads"
    ln -sfn "$SHARED_DIR/uploads" "$RELEASE/uploads"
    cp -f "$REPO_DIR/VERSION" "$RELEASE/VERSION" 2>/dev/null || true
    cd "$RELEASE" && npm install bcryptjs --no-save 2>/dev/null || true
EOF

  chmod 755 "$APP_DIR" "$RELEASES_DIR" "$RELEASE" "$RELEASE/.next"
  chmod -R 755 "$RELEASE/.next/static" "$RELEASE/public"

  [ -f "$RELEASE/server.js" ] || err "server.js nao foi criado em $RELEASE"
}

# Faz swap atomico do current, mata orphans/daemons paralelos, restart pm2.
_swap_and_restart() {
  local RELEASE="$1"

  # 1. Eliminar daemons pm2 paralelos (apanha o caso de pm2 start sem sudo -u imoveo)
  if parallel_pm2_daemons | grep -q .; then
    warn "Daemon pm2 paralelo detectado — a eliminar"
    kill_parallel_pm2 || true
  fi

  # 2. Swap atomico do symlink current
  ln -sfn "$RELEASE" "$CURRENT_DIR" 2>/dev/null || sudo ln -sfn "$RELEASE" "$CURRENT_DIR"
  log "Release activa: $RELEASE"

  # 3. pm2 delete + matar tudo o que reste na porta + pm2 start (estado limpo)
  sudo -u "$APP_USER" pm2 delete imoveo >/dev/null 2>&1 || true
  sleep 1

  local orphan_pid
  orphan_pid=$(ss -tnlp "sport = :$APP_PORT" 2>/dev/null | grep -oP 'pid=\K[0-9]+' | head -1 || true)
  if [ -n "$orphan_pid" ]; then
    warn "Pid $orphan_pid ainda na :$APP_PORT — a eliminar"
    kill -TERM "$orphan_pid" 2>/dev/null || true
    sleep 2
    kill -KILL "$orphan_pid" 2>/dev/null || true
    sleep 1
  fi

  if ss -tnlp "sport = :$APP_PORT" 2>/dev/null | grep -q LISTEN; then
    err "Porta :$APP_PORT ainda ocupada apos cleanup — abortar"
  fi

  sudo -u "$APP_USER" pm2 start "$APP_DIR/ecosystem.config.js"
  sudo -u "$APP_USER" pm2 save >/dev/null 2>&1

  # 4. Aguardar arranque
  log "A aguardar arranque..."
  for i in $(seq 1 30); do
    if curl -sf "http://localhost:$APP_PORT/login" > /dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

cmd_reconcile() {
  log "A reconciliar sistema (release nova a partir do build existente)..."
  local START_TIME
  START_TIME=$(date +%s)

  trap 'maintenance_off' EXIT
  maintenance_on

  local RELEASE
  RELEASE="$RELEASES_DIR/$(date +%s)"

  _create_release "$RELEASE"

  if _swap_and_restart "$RELEASE"; then
    local VERSION
    local END_TIME
    local DURATION
    VERSION=$(cat "$RELEASE/VERSION" 2>/dev/null || echo "?")
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log "Reconcile concluido em ${DURATION}s — v$VERSION"
  else
    warn "App nao respondeu ao health check — verificar logs: imoveo logs"
  fi

  trap - EXIT
  maintenance_off

  # Limpar releases antigas (manter ultimas 5)
  ls -dt "$RELEASES_DIR"/*/ 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true
}

cmd_update() {
  log "A actualizar Imoveo..."
  local START_TIME
  START_TIME=$(date +%s)

  # Garantir que manutencao e desactivada mesmo se o update falhar
  trap 'maintenance_off' EXIT

  # Garantir safe.directory para ambos os users
  git config --global --add safe.directory "$REPO_DIR" 2>/dev/null || true
  sudo -u "$APP_USER" git config --global --add safe.directory "$REPO_DIR" 2>/dev/null || true

  # 1. Pull
  log "A obter ultima versao..."
  cd "$REPO_DIR"
  local PREV_COMMIT
  PREV_COMMIT=$(git rev-parse HEAD)
  sudo -u "$APP_USER" git pull origin main

  local NEW_COMMIT
  NEW_COMMIT=$(git rev-parse HEAD)
  if [ "$PREV_COMMIT" = "$NEW_COMMIT" ]; then
    if validate_current; then
      log "Nenhuma alteracao. Ja esta na ultima versao."
    else
      warn "Nenhuma alteracao no git, mas sistema em DRIFT."
      warn "Corre 'imoveo doctor' para detalhes ou 'imoveo reconcile' para reparar."
    fi
    maintenance_off
    trap - EXIT
    return 0
  fi

  # Activar modo manutencao
  maintenance_on

  # Detectar o que mudou
  local CHANGED
  CHANGED=$(git diff --name-only "$PREV_COMMIT" "$NEW_COMMIT")
  local NEEDS_NPM=false
  local NEEDS_PRISMA=false

  if echo "$CHANGED" | grep -q "package"; then
    NEEDS_NPM=true
    log "  Dependencias npm alteradas — npm ci"
  fi
  if echo "$CHANGED" | grep -q "prisma/"; then
    NEEDS_PRISMA=true
    log "  Schema Prisma alterado — migration necessaria"
  fi

  # 2. Garantir owner correcto no .next (pode ter ficheiros root de operacoes anteriores)
  chown -R "$APP_USER:$APP_USER" "$REPO_DIR/.next" 2>/dev/null || true

  # 3. Instalar dependencias (se necessario)
  sudo -u "$APP_USER" bash -c "
    cd '$REPO_DIR'
    if [ '$NEEDS_NPM' = true ]; then
      npm ci --loglevel=error
    fi
    npx prisma generate
  "

  # 4. Migrations (se necessario)
  if [ "$NEEDS_PRISMA" = true ]; then
    log "A executar migrations..."
    sudo -u "$APP_USER" bash -c "cd '$REPO_DIR' && npx prisma migrate deploy"
  fi

  # 5. Build
  log "A compilar..."
  sudo -u "$APP_USER" bash -c "cd '$REPO_DIR' && npm run build"

  # 6. Criar release + swap + restart (helpers partilhados com cmd_reconcile)
  local RELEASE
  RELEASE="$RELEASES_DIR/$(date +%s)"
  _create_release "$RELEASE"

  if _swap_and_restart "$RELEASE"; then
    local VERSION
    local END_TIME
    local DURATION
    VERSION=$(cat "$RELEASE/VERSION" 2>/dev/null || echo "?")
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    log "Actualizado para v$VERSION em ${DURATION}s"
  else
    warn "App nao respondeu ao health check — verificar logs: imoveo logs"
  fi

  trap - EXIT
  maintenance_off

  # 7. Limpar releases antigas (manter ultimas 5)
  ls -dt "$RELEASES_DIR"/*/ 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true

  # 8. Instalar CLI actualizado (se ha versao nova no repo)
  if [ -f "$REPO_DIR/scripts/imoveo-cli.sh" ]; then
    if ! cmp -s "$REPO_DIR/scripts/imoveo-cli.sh" /usr/local/bin/imoveo; then
      log "CLI actualizado no repo — a instalar nova versao"
      cp "$REPO_DIR/scripts/imoveo-cli.sh" /usr/local/bin/imoveo
      chmod +x /usr/local/bin/imoveo
    fi
  fi
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
  echo "    doctor      Diagnostico read-only (deteca drift)"
  echo "    logs [N]    Ver ultimas N linhas de logs (default: 50)"
  echo "    update      Actualizar para ultima versao (git pull + build + release)"
  echo "    reconcile   Reparar release a partir do build existente (sem git pull)"
  echo "    backup      Criar backup da base de dados"
  echo "    restore     Restaurar backup (imoveo restore <ficheiro>)"
  echo "    rollback    Reverter para release anterior"
  echo "    help        Mostrar esta ajuda"
  echo ""
}

# ---------- Router ----------

case "${1:-help}" in
  start)     cmd_start ;;
  stop)      cmd_stop ;;
  restart)   cmd_restart ;;
  status)    cmd_status ;;
  doctor)    cmd_doctor ;;
  logs)      cmd_logs "$@" ;;
  update)    cmd_update ;;
  reconcile) cmd_reconcile ;;
  backup)    cmd_backup ;;
  restore)   cmd_restore "${2:-}" ;;
  rollback)  cmd_rollback ;;
  help|*)    cmd_help ;;
esac
