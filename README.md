# Imoveo

**Gestao inteligente do seu patrimonio**

Aplicacao web de gestao de patrimonio imobiliario para empresas de subarrendamento em Portugal.

---

## Instalacao Rapida (Producao)

Num servidor Ubuntu 22.04 ou 24.04 LTS recem-instalado (apenas com acesso SSH), execute:

```bash
curl -fsSL https://raw.githubusercontent.com/jotaccf/Imoveo/main/install.sh -o install.sh && bash install.sh
```

A script ira perguntar:
- Dominio (ex: `imoveo.local`)
- Porta da aplicacao (ex: `2020`, `3000`, etc.)
- Password para a base de dados
- Password para o utilizador `deploy`
- Se quer configurar IP fixo
- Email para notificacoes (opcional)

E depois executa automaticamente:
1. Actualizar o sistema
2. Instalar Docker, Nginx, Firewall (UFW)
3. Criar utilizador dedicado `deploy`
4. Configurar IP fixo (se solicitado)
5. Clonar o repositorio e configurar ambiente
6. Arrancar a aplicacao com Docker Compose
7. Executar migrations e seed da base de dados
8. Configurar backups diarios automaticos
9. Configurar monitoramento com reinicio automatico

**Nao e necessario conhecimento de Linux** — a script trata de tudo. Basta responder as perguntas.

A script e **segura para re-executar** — salta passos ja concluidos.

### Apos a instalacao

A script mostra um resumo com o URL, IP, porta e credenciais. Para aceder ao Imoveo, adicione ao DNS local da sua rede ou ao ficheiro hosts do seu computador:

**Windows** — editar `C:\Windows\System32\drivers\etc\hosts` (como Administrador):
```
IP_DO_SERVIDOR  imoveo.local
```

**macOS/Linux** — editar `/etc/hosts`:
```
IP_DO_SERVIDOR  imoveo.local
```

(Substitua `IP_DO_SERVIDOR` pelo IP mostrado no resumo da instalacao)

Depois abra o browser: **http://imoveo.local**

### Credenciais iniciais

| Perfil | Email | Password |
|---|---|---|
| Admin | admin@imoveo.local | Imoveo2024! |
| Gestor | gestor@imoveo.local | Imoveo2024! |
| Operador | operador@imoveo.local | Imoveo2024! |

**Altere as passwords imediatamente apos o primeiro login** em Administracao > Utilizadores.

---

## Actualizacoes

Para actualizar a aplicacao no servidor:

```bash
su - deploy
cd /opt/imoveo
git pull origin main
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
```

Se houver alteracoes a base de dados (ver CHANGELOG):
```bash
# Obter a password do PostgreSQL
grep POSTGRES_PASSWORD .env.prod

# Executar migrations (substituir PASSWORD pelo valor real)
docker compose -f docker-compose.prod.yml --env-file .env.prod exec -T \
  -e 'DATABASE_URL=postgresql://imoveo:PASSWORD@postgres:5432/imoveo' \
  app npx prisma migrate deploy
```

Ou re-executar a script de instalacao (e segura para re-executar):
```bash
curl -fsSL https://raw.githubusercontent.com/jotaccf/Imoveo/main/install.sh -o install.sh && bash install.sh
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
su - deploy
/opt/imoveo/backup.sh
```

### Restaurar backup

```bash
su - deploy
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
crontab -e
# Adicionar linha:
# 30 2 * * * cp $(ls -t /opt/backups/imoveo/*.sql.gz | head -1) /mnt/backup-externo/
```

**Opcao 2 — SFTP para outro servidor:**
```bash
# Adicionar ao crontab:
# 30 2 * * * scp $(ls -t /opt/backups/imoveo/*.sql.gz | head -1) user@servidor-remoto:/backups/
```

**Opcao 3 — AWS S3:**
```bash
sudo apt install awscli
aws configure
# Adicionar ao crontab:
# 30 2 * * * aws s3 cp $(ls -t /opt/backups/imoveo/*.sql.gz | head -1) s3://meu-bucket/imoveo/
```

**Opcao 4 — Google Drive (rclone):**
```bash
curl https://rclone.org/install.sh | sudo bash
rclone config  # configurar Google Drive
# Adicionar ao crontab:
# 30 2 * * * rclone copy /opt/backups/imoveo/ gdrive:backups/imoveo/ --include "*.sql.gz"
```

---

## Comandos Uteis

```bash
# Aceder como utilizador deploy
su - deploy
cd /opt/imoveo

# Ver estado dos servicos
docker compose -f docker-compose.prod.yml ps

# Ver logs em tempo real
docker compose -f docker-compose.prod.yml logs -f app

# Ver logs do PostgreSQL
docker compose -f docker-compose.prod.yml logs -f postgres

# Reiniciar servicos
docker compose -f docker-compose.prod.yml --env-file .env.prod restart

# Parar tudo
docker compose -f docker-compose.prod.yml down

# Arrancar tudo
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d

# Aceder a base de dados
docker compose -f docker-compose.prod.yml exec postgres psql -U imoveo imoveo

# Ver health check
curl http://localhost:PORTA/api/health

# Ver log de health checks
cat /opt/backups/imoveo/health.log

# Ver log de backups
cat /opt/backups/imoveo/backup.log

# Ver configuracao actual
cat .env.prod
```

(Substitua `PORTA` pela porta que definiu na instalacao)

---

## Funcionalidades

### Gestao de Imoveis
- Imoveis com quartos (fracoes) e reordenacao manual
- Centros de custo protegidos (Despesas Gerais, Despesas Pessoais)
- Ocupacao real baseada em faturas emitidas
- Data de entrada no mercado por quarto
- Detalhe por imovel com racios financeiros

### Importacao e-Fatura
- CSV do portal e-Fatura (recebidas e emitidas)
- Deteccao automatica de tipo e periodo
- Deduplicacao SHA-256 (ficheiro e fatura)
- Notas de credito (valores negativos), documentos anulados (ignorados)

### Classificacao
- Automatica por mapeamento NIF com regras persistentes
- Batch de multiplas faturas num clique
- Propagacao de regras para pendentes existentes
- Suporte a quartos (fracoes) na classificacao

### Lancamentos Manuais
- Multi-mes com nr. documento e data por mes
- Retencao na fonte (0%, 11.5%, 25%) com calculo automatico
- IVA por dropdown (23%, 13%, 6%, Isento)
- Auto-preenchimento por tipo de documento
- Campos obrigatorios: Imovel, Valor, Fornecedor, NIF

### Analise Financeira
- Dashboard com vista detalhada e simples
- Rentabilidade por imovel com potencial de receita
- Evolucao mensal (receita vs gastos vs resultado)
- Indicadores de risco (vacancia, concentracao, racio cobertura)
- Custos operacionais (distribuicao donut, evolucao area, ranking)
- Previsao IRC (PME, derrama, pagamento por conta, retencoes)
- Regime de acrescimo para receitas (cross-year)

### Calculadora Financeira
- Yield bruta/liquida, ROI, Payback (capital e total)
- DSCR (Debt Service Coverage Ratio) com gauge visual
- Ponto de equilibrio com calendario e cenarios de ocupacao
- Simulador de credito/leasing (Euribor + spread)
- Comparacao de portfolio (dados reais + simulacao)

### Configuracoes
- Derrama municipal, regime PME, taxas IRC
- Taxa de retencao na fonte
- Parametros editaveis pelo administrador

---

## Stack Tecnologica

| Componente | Tecnologia |
|---|---|
| Framework | Next.js 16 (Turbopack) |
| Linguagem | TypeScript 5 |
| Base de dados | PostgreSQL 16 |
| ORM | Prisma 7 (adapter PrismaPg) |
| Autenticacao | NextAuth v5 (JWT) |
| UI | Tailwind CSS v4 |
| Graficos | Recharts |
| Testes | Jest + ts-jest |
| Containerizacao | Docker Compose |

---

## Desenvolvimento Local

```bash
git clone https://github.com/jotaccf/Imoveo.git
cd Imoveo
npm install
docker compose up -d          # PostgreSQL local (porta 5433)
cp .env.example .env.local    # Editar credenciais
npx prisma generate
npx prisma migrate dev
npx prisma db seed
npm run dev                   # http://localhost:3000
```

### Testes

```bash
npm test              # Correr testes (81 testes)
npm run test:coverage # Com cobertura
```

---

## Permissoes (RBAC)

3 perfis com 24 permissoes granulares:

| Funcionalidade | Admin | Gestor | Operador |
|---|---|---|---|
| Dashboard completo | ✅ | ✅ | ❌ |
| Dashboard basico | ✅ | ✅ | ✅ |
| Gestao de imoveis | ✅ | ❌ | ❌ |
| Ver imoveis | ✅ | ✅ | ❌ |
| Importar CSV | ✅ | ✅ | ✅ |
| Classificar pendentes | ✅ | ✅ | ✅ |
| Lancamentos (criar) | ✅ | ✅ | ✅ |
| Lancamentos (editar) | ✅ | ✅ | ❌ |
| Lancamentos (remover) | ✅ | ❌ | ❌ |
| Analise financeira | ✅ | ✅ | ❌ |
| Custos operacionais | ✅ | ✅ | ❌ |
| Previsao IRC | ✅ | ✅ | ❌ |
| Calculadora | ✅ | ✅ | ❌ |
| Mapeamento NIF | ✅ | ✅ | ❌ |
| Configuracoes | ✅ | ❌ | ❌ |
| Gestao utilizadores | ✅ | ❌ | ❌ |

---

## Licenca

Privado. Todos os direitos reservados.
