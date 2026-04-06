# Imoveo

**Gestao inteligente do seu patrimonio**

Aplicacao web de gestao de patrimonio imobiliario para empresas de subarrendamento em Portugal.

---

## Instalacao Rapida (Producao)

Num servidor Ubuntu 22.04 ou 24.04 LTS recem-instalado (apenas com acesso SSH), execute:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jotaccf/Imoveo/main/install.sh)
```

Metodos alternativos (todos funcionam):
```bash
# Descarregar e executar
curl -fsSL https://raw.githubusercontent.com/jotaccf/Imoveo/main/install.sh -o install.sh && bash install.sh

# Ou
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jotaccf/Imoveo/main/install.sh)"
```

A script ira:
1. Actualizar o sistema
2. Instalar Docker, Nginx, Firewall
3. Criar utilizador dedicado `deploy`
4. Perguntar o dominio (ex: `imoveo.local`) e a porta
5. Clonar o repositorio e configurar tudo
6. Arrancar a aplicacao
7. Configurar backups diarios automaticos
8. Configurar monitoramento com reinicio automatico

**Nao e necessario conhecimento de Linux** — a script trata de tudo. Basta responder as perguntas que aparecem no ecra.

### Apos a instalacao

A script mostra um resumo com o URL e as credenciais. Para aceder ao Imoveo, adicione ao DNS local da sua rede ou ao ficheiro hosts do seu computador:

**Windows** — editar `C:\Windows\System32\drivers\etc\hosts`:
```
192.168.1.50  imoveo.local
```

**macOS/Linux** — editar `/etc/hosts`:
```
192.168.1.50  imoveo.local
```

(Substitua `192.168.1.50` pelo IP do servidor Ubuntu)

Depois abra o browser: **http://imoveo.local**

### Credenciais iniciais

| Perfil | Email | Password |
|---|---|---|
| Admin | admin@imoveo.local | Imoveo2024! |
| Gestor | gestor@imoveo.local | Imoveo2024! |
| Operador | operador@imoveo.local | Imoveo2024! |

**Altere as passwords imediatamente apos o primeiro login.**

---

## Actualizacoes

Para actualizar a aplicacao no servidor:

```bash
sudo su - deploy
cd /opt/imoveo
git pull origin main
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
docker compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy
```

---

## Backups

Os backups sao realizados **automaticamente todos os dias as 02:00**.

- **Localizacao:** `/opt/backups/imoveo/`
- **Formato:** `imoveo_YYYYMMDD_HHMMSS.sql.gz` (comprimido)
- **Retencao:** ultimos 30 dias (os mais antigos sao eliminados automaticamente)
- **Log:** `/opt/backups/imoveo/backup.log`

### Backup manual

```bash
sudo su - deploy
/opt/imoveo/backup.sh
```

### Restaurar backup

```bash
sudo su - deploy
cd /opt/imoveo
gunzip /opt/backups/imoveo/imoveo_YYYYMMDD_HHMMSS.sql.gz
docker compose -f docker-compose.prod.yml exec -T postgres \
  psql -U imoveo imoveo < /opt/backups/imoveo/imoveo_YYYYMMDD_HHMMSS.sql
```

### Configurar backup externo (opcional)

Para copiar backups para um local externo, adicione uma das seguintes opcoes:

**Opcao 1 — Pasta partilhada na rede (NFS/SMB):**
```bash
# Montar pasta partilhada
sudo mount -t cifs //192.168.1.100/backups /mnt/backup-externo -o username=user,password=pass

# Adicionar ao crontab (apos o backup diario)
sudo -u deploy crontab -e
# Adicionar linha:
# 30 2 * * * cp /opt/backups/imoveo/$(ls -t /opt/backups/imoveo/*.sql.gz | head -1) /mnt/backup-externo/
```

**Opcao 2 — SFTP para outro servidor:**
```bash
# Adicionar ao crontab:
# 30 2 * * * scp /opt/backups/imoveo/$(ls -t /opt/backups/imoveo/*.sql.gz | head -1) user@servidor-remoto:/backups/
```

**Opcao 3 — AWS S3:**
```bash
# Instalar AWS CLI
sudo apt install awscli
aws configure

# Adicionar ao crontab:
# 30 2 * * * aws s3 cp /opt/backups/imoveo/$(ls -t /opt/backups/imoveo/*.sql.gz | head -1) s3://meu-bucket/imoveo/
```

**Opcao 4 — Google Drive (rclone):**
```bash
# Instalar rclone
curl https://rclone.org/install.sh | sudo bash
rclone config  # configurar Google Drive

# Adicionar ao crontab:
# 30 2 * * * rclone copy /opt/backups/imoveo/ gdrive:backups/imoveo/ --include "*.sql.gz"
```

---

## Comandos Uteis

```bash
# Aceder ao servidor como utilizador deploy
sudo su - deploy

# Ver estado dos servicos
cd /opt/imoveo
docker compose -f docker-compose.prod.yml ps

# Ver logs em tempo real
docker compose -f docker-compose.prod.yml logs -f app

# Reiniciar servicos
docker compose -f docker-compose.prod.yml restart

# Parar tudo
docker compose -f docker-compose.prod.yml down

# Aceder a base de dados
docker compose -f docker-compose.prod.yml exec postgres psql -U imoveo imoveo

# Ver health check
curl http://localhost:3000/api/health

# Ver log de health checks
cat /opt/backups/imoveo/health.log

# Ver log de backups
cat /opt/backups/imoveo/backup.log
```

---

## Funcionalidades

### Gestao de Imoveis
- Imoveis com quartos (fracoes) e reordenacao manual
- Centros de custo (Despesas Gerais, Despesas Pessoais)
- Ocupacao real baseada em faturas emitidas
- Data de entrada no mercado por quarto

### Importacao e-Fatura
- CSV do portal e-Fatura (recebidas e emitidas)
- Deteccao automatica de tipo e periodo
- Deduplicacao SHA-256
- Notas de credito (valores negativos), documentos anulados (ignorados)

### Classificacao
- Automatica por mapeamento NIF
- Batch de multiplas faturas
- Propagacao de regras para pendentes existentes

### Lancamentos Manuais
- Multi-mes com nr. documento e data por mes
- Retencao na fonte (0%, 11.5%, 25%)
- IVA por dropdown (23%, 13%, 6%, Isento)

### Analise Financeira
- Dashboard com vista detalhada/simples
- Rentabilidade por imovel com potencial de receita
- Evolucao mensal, indicadores de risco
- Custos operacionais (distribuicao, evolucao, ranking)
- Previsao IRC (PME, derrama, pagamento por conta)

### Calculadora Financeira
- Yield, ROI, Payback (capital e total)
- DSCR com gauge visual
- Ponto de equilibrio com cenarios
- Simulador de credito/leasing (Euribor + spread)
- Portfolio

---

## Stack Tecnologica

| Componente | Tecnologia |
|---|---|
| Framework | Next.js 16 (Turbopack) |
| Linguagem | TypeScript 5 |
| Base de dados | PostgreSQL 16 |
| ORM | Prisma 7 |
| Autenticacao | NextAuth v5 (JWT) |
| UI | Tailwind CSS v4 |
| Graficos | Recharts |
| Testes | Jest |
| Containerizacao | Docker Compose |

---

## Desenvolvimento Local

```bash
git clone https://github.com/jotaccf/Imoveo.git
cd Imoveo
npm install
docker compose up -d          # PostgreSQL local
cp .env.example .env.local    # Configurar credenciais
npx prisma generate
npx prisma migrate dev
npx prisma db seed
npm run dev                   # http://localhost:3000
```

### Testes

```bash
npm test              # Correr testes
npm run test:coverage # Com cobertura
```

---

## Permissoes (RBAC)

| Funcionalidade | Admin | Gestor | Operador |
|---|---|---|---|
| Dashboard completo | ✅ | ✅ | ❌ |
| Gestao de imoveis | ✅ | ❌ | ❌ |
| Ver imoveis | ✅ | ✅ | ❌ |
| Importar CSV | ✅ | ✅ | ✅ |
| Classificar pendentes | ✅ | ✅ | ✅ |
| Lancamentos (criar) | ✅ | ✅ | ✅ |
| Lancamentos (editar) | ✅ | ✅ | ❌ |
| Analise financeira | ✅ | ✅ | ❌ |
| Configuracoes | ✅ | ❌ | ❌ |
| Gestao utilizadores | ✅ | ❌ | ❌ |

---

## Licenca

Privado. Todos os direitos reservados.
