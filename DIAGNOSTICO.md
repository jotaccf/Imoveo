# Imoveo — Guia de Diagnostico (Bare Metal)

Runbook para identificar e resolver problemas comuns em producao.

> Para deploy inicial ver [DEPLOY.md](./DEPLOY.md). Este documento assume
> sistema ja instalado em `/opt/imoveo/` com o CLI `/usr/local/bin/imoveo`.

---

## 1. Verificacao rapida

Antes de qualquer outra coisa:

```bash
sudo imoveo doctor
```

Devera mostrar 9 OK. Qualquer FAIL aponta para a seccao correspondente
abaixo.

```
=== IMOVEO Doctor — Diagnostico ===

  OK   current symlink — /opt/imoveo/releases/...
  OK   server.js existe — XXXX bytes
  OK   .env → shared
  OK   pm2 daemons — apenas imoveo
  OK   pm2 status imoveo — online
  OK   app HTTP :3000 — responde
  OK   PostgreSQL — responde
  OK   versao build = repo — v1.x.x
  OK   nginx static path — /opt/imoveo/current/.next/static

  Tudo OK (9 checks passaram)
```

---

## 2. Estrutura do sistema

```
/opt/imoveo/
├── repo/                    # git repo (origem do build)
│   ├── .env -> shared/.env  # symlink
│   └── .next/standalone/    # output do npm run build
├── releases/<timestamp>/    # release blue-green com server.js + .next/static
├── current -> releases/...  # symlink para a release activa
├── shared/
│   ├── .env                 # FONTE UNICA das credenciais
│   └── uploads/             # ficheiros persistentes (plantas, contratos)
├── logs/                    # logs do pm2 (out.log, error.log)
└── ecosystem.config.js      # config pm2

/usr/local/bin/imoveo        # CLI de gestao
/etc/nginx/sites-enabled/imoveo            # config nginx producao
/etc/nginx/sites-enabled/imoveo-maintenance # config nginx manutencao
```

**Invariantes:**
- `current` e symlink para `/opt/imoveo/releases/<timestamp>/`
- `current/.env` resolve para `/opt/imoveo/shared/.env`
- `current/server.js` existe
- Apenas UM daemon pm2 a correr (user `imoveo`)
- App escuta em `:3000`

---

## 3. Problemas comuns

### 3.1 App nao responde / HTTP 502

**Sintomas:**
- Browser mostra "502 Bad Gateway"
- `imoveo doctor` falha em `app HTTP :3000`

**Diagnostico:**
```bash
sudo -u imoveo pm2 status                # online?
sudo -u imoveo pm2 logs imoveo --lines 30 --nostream --err
sudo ss -tnlp | grep :3000               # ha alguem na porta?
```

**Resolucao:**
1. Se pm2 mostra "errored" ou "waiting restart": ver erro nos logs
2. Se nada esta na :3000: `sudo imoveo restart`
3. Se pm2 esta em loop com `MODULE_NOT_FOUND`: `sudo imoveo reconcile`

---

### 3.2 pm2 em loop de restart (EADDRINUSE)

**Sintomas:**
- `pm2 status` mostra `unstable restarts` elevado
- Logs mostram repetidamente `Error: listen EADDRINUSE: address already in use 0.0.0.0:3000`

**Causa tipica:**
- Existe um **daemon pm2 paralelo** (outro user) a correr a app
- Ou um child orphan do `next-server` que segura o socket

**Diagnostico:**
```bash
ps -ef | grep "PM2 .* God Daemon" | grep -v grep
# Deve aparecer apenas: imoveo ... /opt/imoveo/.pm2
# Se aparecer tambem jotaccf ... /home/jotaccf/.pm2 → daemon paralelo
```

**Resolucao automatica:**
```bash
sudo imoveo reconcile
```
O `reconcile` ja deteca e elimina daemons paralelos automaticamente.

**Resolucao manual (se imoveo CLI nao estiver disponivel):**
```bash
# 1. Matar daemons paralelos (substituir <user> por todos os users nao-imoveo)
sudo -u <user> pm2 delete all
sudo -u <user> pm2 kill

# 2. Matar tudo na :3000
sudo fuser -k -KILL 3000/tcp

# 3. Restart limpo
sudo -u imoveo pm2 delete imoveo
sudo -u imoveo pm2 start /opt/imoveo/ecosystem.config.js
sudo -u imoveo pm2 save
```

**Prevencao:** SEMPRE usar `sudo -u imoveo pm2 ...` para comandos manuais.
Considerar alias no `.bashrc`: `alias pm2='sudo -u imoveo pm2'`.

---

### 3.3 Static chunks 404 (Turbopack/Webpack)

**Sintomas:**
- Dashboard fica em "A carregar..." indefinidamente
- DevTools (F12) → Network mostra 404 em `/_next/static/chunks/...`
- Login funciona mas a app nao carrega

**Causa:** Nginx serve `/_next/static/` de `/opt/imoveo/current/.next/static/`.
Se o `current` symlink aponta para um sitio errado (ex: `repo` directo), o
build novo nao e visivel via Nginx.

**Diagnostico:**
```bash
# Onde aponta o current?
ls -la /opt/imoveo/current

# Os ficheiros existem?
ls /opt/imoveo/current/.next/static/chunks/ | head -5

# Que chunks o HTML pede?
curl -s http://localhost:3000/login | grep -oE 'turbopack-[a-z0-9-]+\.js' | head -3
```

**Resolucao:** `sudo imoveo reconcile` (recria release com static no sitio
correcto e re-aponta current).

---

### 3.4 Sessao "Boas-vindas, ." (nome vazio)

**Sintomas:**
- Apos login, dashboard mostra "Boas-vindas, ." sem nome
- Sidebar so mostra items que nao requerem permissao (Dashboard, Importar CSV, etc.)
- Em janela anonima funciona correctamente

**Causa:** Cookie de sessao antigo no browser do utilizador (token JWT
sem `nome`/`role` populados, ou encriptado com `NEXTAUTH_SECRET` antigo).

**Resolucao para o utilizador (local):**
1. F12 → Application → Storage → **Clear site data**
2. Login de novo

**Se persistir mesmo apos Clear site data:**
- Pode ser cache agressivo do browser ou Service Worker
- Tenta: F12 → Application → Service Workers → Unregister
- E `Ctrl+Shift+Delete` → "All time" → Cookies + Cached files → Clear

**Resolucao universal (forca relogin de TODOS os utilizadores):**
```bash
# Rotar NEXTAUTH_SECRET
NEW=$(openssl rand -base64 48 | tr -d '=' | tr '/+' '_-')
sudo bash -c "awk -v s='$NEW' '
  /^NEXTAUTH_SECRET=/ { print \"NEXTAUTH_SECRET=\\\"\" s \"\\\"\"; next }
  { print }
' /opt/imoveo/shared/.env > /opt/imoveo/shared/.env.new && \
chown imoveo:imoveo /opt/imoveo/shared/.env.new && \
chmod 600 /opt/imoveo/shared/.env.new && \
mv /opt/imoveo/shared/.env.new /opt/imoveo/shared/.env"

sudo -u imoveo pm2 reload imoveo --update-env
```

---

### 3.5 EACCES em ficheiros apos operacoes manuais

**Sintomas:**
- `npm run build` falha com `EACCES: permission denied, unlink '...'`
- Update CLI falha em algures durante o build

**Causa:** Algum ficheiro em `/opt/imoveo/repo/.next/` ficou com owner errado
(provavelmente root) apos operacoes manuais.

**Resolucao:**
```bash
sudo chown -R imoveo:imoveo /opt/imoveo/repo/.next
```

A v1.4.3 do CLI ja inclui isto no `cmd_update` automaticamente.

---

### 3.6 Drift do blue-green (current → repo em vez de release)

**Sintomas:**
- `imoveo doctor` mostra: `FAIL current symlink — aponta para /opt/imoveo/repo`
- App pode funcionar mas o modelo blue-green nao
- Updates futuros podem falhar de forma estranha

**Causa:** Recuperacao manual de incidente onde alguem fez
`ln -sfn /opt/imoveo/repo /opt/imoveo/current` em vez de apontar para uma
release em `/opt/imoveo/releases/`.

**Resolucao:** `sudo imoveo reconcile`

---

### 3.7 `.env` com password errada / dessincronizado

**Sintomas:**
- App responde mas operacoes de BD falham com "28P01: password authentication failed"
- Multiplos `.env` com passwords diferentes

**Diagnostico:**
```bash
echo "--- shared ---"; sudo grep DATABASE_URL /opt/imoveo/shared/.env
echo "--- repo ---";   sudo grep DATABASE_URL /opt/imoveo/repo/.env
echo "--- current ---";sudo grep DATABASE_URL /opt/imoveo/current/.env
```

Todos devem mostrar a **mesma** password. Se diferentes, alguem alterou
manualmente sem consolidar.

**Resolucao (consolidar para fonte unica):**
```bash
# 1. Decidir qual e a password correcta (testar com psql)
PGPASSWORD="<password>" psql -h 127.0.0.1 -U imoveo -d imoveo -c "SELECT 1;"

# 2. Aplicar essa password ao shared/.env (fonte unica)
sudo nano /opt/imoveo/shared/.env

# 3. Tornar repo/.env e standalone/.env symlinks para shared/.env
sudo rm /opt/imoveo/repo/.env
sudo -u imoveo ln -s /opt/imoveo/shared/.env /opt/imoveo/repo/.env

sudo rm -f /opt/imoveo/repo/.next/standalone/.env
sudo -u imoveo ln -s /opt/imoveo/shared/.env /opt/imoveo/repo/.next/standalone/.env

# 4. Restart
sudo -u imoveo pm2 reload imoveo --update-env
```

---

### 3.8 Rotar password da BD (compromisso ou expirou)

**Quando fazer:** Suspeita de comprometimento, ou rotacao periodica.

```bash
# 1. Gerar nova password (hex puro evita caracteres especiais)
NEW=$(openssl rand -hex 24)
echo "Guarda: $NEW"

# 2. Backup
sudo cp /opt/imoveo/shared/.env /opt/imoveo/shared/.env.bak.$(date +%s)

# 3. Preparar .env novo num temp file (atomico depois)
sudo bash -c "awk -v p='$NEW' '
  /^DATABASE_URL=/ { sub(/:[^:@]+@/, \":\" p \"@\"); }
  { print }
' /opt/imoveo/shared/.env > /opt/imoveo/shared/.env.new && \
chown imoveo:imoveo /opt/imoveo/shared/.env.new && \
chmod 600 /opt/imoveo/shared/.env.new"

# 4. ALTER USER no postgres
sudo -u postgres psql -c "ALTER USER imoveo WITH PASSWORD '$NEW';"

# 5. Atomic move do .env
sudo mv /opt/imoveo/shared/.env.new /opt/imoveo/shared/.env

# 6. Reload pm2 (Postgres mantem sessoes activas → sem queda)
sudo -u imoveo pm2 reload imoveo --update-env

# 7. Validar
PGPASSWORD="$NEW" psql -h 127.0.0.1 -U imoveo -d imoveo -c "SELECT 1;"
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:3000/login

# 8. Guardar a password no gestor de senhas e apagar do historico:
history -d $(history | tail -20 | grep "ALTER USER" | head -1 | awk '{print $1}')
```

---

### 3.9 Recuperar acesso quando admin perdeu password

```bash
# 1. Gerar hash bcryptjs da nova password
NEW="<nova_password>"
HASH=$(sudo -u imoveo bash -c "cd /opt/imoveo/repo && \
  node -e 'console.log(require(\"bcryptjs\").hashSync(\"$NEW\", 12))'")

# 2. Update no PostgreSQL
sudo -u postgres psql -d imoveo -c "
  UPDATE utilizadores SET \"passwordHash\" = '$HASH', ativo = true
  WHERE email = 'admin@imoveo.local';"

# 3. Login
```

---

### 3.10 Build standalone sem self-healing JWT

**Sintomas:**
- Mesmo apos `Clear site data` no browser, sessao continua sem `nome`/`role`
- `/api/auth/session` retorna user sem esses campos

**Causa:** Build em `current/.next/server/` e anterior a v1.4.1 (sem o
codigo do self-healing JWT no `auth.ts`).

**Diagnostico:**
```bash
# Versao do repo vs versao do build
cat /opt/imoveo/repo/VERSION
cat /opt/imoveo/current/VERSION

# Procurar funcao do self-healing no build compilado
sudo grep -roE "token\.role.*token\.nome" /opt/imoveo/current/.next/server/ | head -3
```

**Resolucao:**
```bash
# Garantir owner do .next
sudo chown -R imoveo:imoveo /opt/imoveo/repo/.next

# Rebuild + reconcile
sudo -u imoveo bash -c "cd /opt/imoveo/repo && npm run build"
sudo imoveo reconcile
```

---

## 4. Comandos uteis

```bash
# Estado geral
sudo imoveo status
sudo imoveo doctor

# Logs (default ultimas 50 linhas)
sudo imoveo logs [N]

# Operacoes ciclo de vida
sudo imoveo start      # arrancar
sudo imoveo stop       # parar
sudo imoveo restart    # reiniciar
sudo imoveo update     # git pull + build + release nova + restart
sudo imoveo reconcile  # recriar release a partir do build existente (sem git pull)
sudo imoveo rollback   # voltar a release anterior

# Backup e restore
sudo imoveo backup
sudo imoveo restore <ficheiro>

# Acesso directo aos componentes
sudo -u imoveo pm2 status
sudo -u imoveo pm2 logs imoveo
sudo -u imoveo pm2 describe imoveo
sudo nginx -t              # validar config nginx
sudo systemctl status nginx postgresql

# BD directa (extrair credenciais do .env)
DB_URL=$(sudo grep DATABASE_URL /opt/imoveo/shared/.env | cut -d'"' -f2)
PGPASSWORD=$(echo "$DB_URL" | sed -n 's|.*://.*:\(.*\)@.*|\1|p') \
  psql -h 127.0.0.1 -U imoveo -d imoveo
```

---

## 5. Logs

```
/opt/imoveo/logs/out.log       # stdout do pm2
/opt/imoveo/logs/error.log     # stderr do pm2
/opt/imoveo/debug.log          # debug logger interno da app
/var/log/nginx/access.log      # acessos HTTP
/var/log/nginx/error.log       # erros nginx
/opt/backups/imoveo/           # backups SQL + logs de update
```

---

## 6. Quando contactar suporte

Antes de pedir ajuda, corre e cola output de:

```bash
sudo imoveo doctor
sudo imoveo status
sudo imoveo logs 50 --nostream
```

Inclui tambem:
- O que foi feito antes do problema aparecer
- Screenshots do browser se for UI
- Output de `/api/admin/debug` (visivel para admin em `/api/admin/debug`)

---

## 7. Operacoes destrutivas

**NUNCA correr sem confirmacao do que estas a fazer:**

```bash
# DROP da BD — perde TODOS os dados
sudo -u postgres dropdb imoveo

# Apagar repo
rm -rf /opt/imoveo/repo

# Reset de password sem hashing — partir login completamente
sudo -u postgres psql -c "UPDATE utilizadores SET \"passwordHash\" = '...'"
```

Antes destas operacoes, sempre `sudo imoveo backup`.
