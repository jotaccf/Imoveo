# Imoveo — Roadmap

## v1.0.0 — Base Completa ✅ Released (2026-04-06)
- [x] Setup Next.js 16 + TypeScript + Tailwind v4
- [x] Schema Prisma completo (11 modelos, 13 enums)
- [x] Autenticacao NextAuth v5 (RBAC 3 perfis, 24 permissoes)
- [x] Parser CSV e-Fatura (recebidas + emitidas, deteccao automatica)
- [x] Deduplicacao SHA-256 (ficheiro + fatura)
- [x] Classificacao automatica por NIF + classificacao batch
- [x] API Routes completa com paginacao server-side
- [x] Dashboard com vista detalhada/simples
- [x] Gestao de imoveis com quartos (fracoes) e reordenacao
- [x] Centros de custo (Despesas Gerais, Pessoais)
- [x] Lancamentos manuais com multi-mes e retencao na fonte
- [x] Analise financeira (rentabilidade, cash flow, risco, IRC)
- [x] Custos operacionais (distribuicao, evolucao, ranking)
- [x] Calculadora financeira (yield, DSCR, break-even, portfolio)
- [x] Simulador de credito/leasing
- [x] Detalhe por imovel com racios e avaliacao
- [x] Configuracoes fiscais editaveis
- [x] Docker Compose dev + producao
- [x] Ficheiros Electron (desktop app)
- [x] Guia de deploy (DEPLOY.md)

## v1.0.1 — Backup e PDF (2026-04-06)
- [x] Backup/restore de dados via interface
- [x] Exportacao PDF de analise financeira
- [x] Fix: restore limpa schema antes de importar (evita conflitos)

## v1.0.2 — Contratos e Manutencao (2026-04-06)
- [x] Gestao de contratos de arrendamento (inquilino, fiador, renovacao)
- [x] Comunicacao AT por contrato (toggle na listagem)
- [x] Modo manutencao B+ para updates (pagina Nginx + logs tempo real)
- [x] Update watcher via cron no host (resolve container a morrer durante rebuild)
- [x] Endpoint /api/admin/debug (diagnostico completo do sistema)
- [x] Debug logger temporario para troubleshooting producao

## v1.1.0 — Melhorias UX e Reporting ✅ Released (2026-04-06)
- [x] Comparacao YoY (ano vs ano anterior)
- [x] Alertas automaticos por threshold (yield, ocupacao, racio, margem)
- [x] Dashboard de gestao de contratos (expiracoes, renovacoes, projecao receita)
- [x] Validacao de contrato unico por fracao (impede duplicados)
- [x] Indicador de versao no sidebar
- [x] Sudoers expandido para deploy (nginx, mkdir, cp, chown, ln, rm)
- [x] update.sh auto-configura cron, manutencao e nginx no host

## v1.2.0 — Contratos PDF, Uploads e Tailscale ✅ Released (2026-04-07)
- [x] Geracao PDF de contrato de subarrendamento (texto legal completo, 12 clausulas)
- [x] Campos dinamicos: genero, nacionalidade, documento, proprietarios, despesas
- [x] Formulario imovel com tabs (Geral, Contrato, Proprietarios, Equipamentos)
- [x] Formulario fracao com detalhes (letra, tipo quarto, casa banho, mobilia)
- [x] Formulario contrato com identificacao inquilino + assinatura
- [x] Dados da empresa nas configuracoes (Primeira Outorgante)
- [x] Upload planta do imovel (PDF/JPG/PNG) com merge no contrato PDF
- [x] Upload contrato assinado com check verde na tabela
- [x] Copia local do contrato PDF gerado
- [x] Tailscale VPN nas configuracoes (auth key + estado)
- [x] Configuracoes com seccoes colapsaveis
- [x] Fix: pendentes mostra total real (nao limitado a 50)
- [x] Fix: psql/pg_dump com path completo (bare metal compativel)
- [x] Fix: assinaturas sempre na mesma pagina do PDF
- [x] Fix: bcryptjs incluido no standalone output

## v1.2.1 — Fixes bare metal (2026-04-07)
- [x] sudo chmod no update para permissoes de estaticos Nginx
- [x] npm ci --loglevel=error (sem warnings durante update)

## v1.3.0 — Config Fiscal por Ano + Prejuizos ✅ Released (2026-05-11)
- [x] Configuracao fiscal por ano (taxa IRC, derrama, prejuizos reportaveis)
- [x] Reporte de prejuizos no calculo IRC (Art. 52.º CIRC, limite 70%)

## v1.3.1 — UI Config Fiscal ✅ Released (2026-05-11)
- [x] Editor de configuracao fiscal por ano na pagina /configuracoes

## v1.4.0 — Activos Fixos + Tributacao Autonoma ✅ Released (2026-05-12)
- [x] Activos Fixos: viaturas e equipamentos (CRUD)
- [x] Tributacao Autonoma para viaturas (combustao/hibrido/GPL/electrico)
- [x] Pagamentos por Conta (PCC) — Art. 105.º CIRC
- [x] Depreciacoes para imoveis ADQUIRIDOS (DR 25/2009)
- [x] Tipo de imovel INDUSTRIAL (depreciacao 5%)
- [x] Encargos nao dedutiveis (toggle dedutivel por rubrica)
- [x] Simulador What-if com sliders (receita/custos)
- [x] Bloqueio de quartos em imoveis nao-residenciais (INDUSTRIAL, LOJA, ESCRITORIO)
- [x] Validacao TOC: retencoes IRS sobre rendas NAO deduzem IRC (Art. 101.º CIRS)

## v1.4.1 — Self-healing JWT ✅ Released (2026-05-12)
- [x] Revalidacao de token contra BD em cada request
- [x] Invalidacao de tokens corrompidos/antigos (retorna null)
- [x] TTL reduzido para 8h (em vez do default 30 dias)
- [x] Deteccao de users desactivados/eliminados

## v1.4.2 — Patch de Seguranca ✅ Released (2026-05-12)
- [x] 13 vulnerabilidades patched (8 moderate + 5 high)
- [x] Next 16.2.2 → 16.2.6
- [x] axios, xmldom, fast-uri, fast-xml-parser actualizados

## v1.4.3 — CLI Robusto + Documentacao ✅ Released (2026-05-12)
- [x] scripts/imoveo-cli.sh versionado no repo (auto-install via update)
- [x] imoveo doctor — diagnostico read-only (9 checks)
- [x] imoveo reconcile — repara drift sem precisar de novo commit
- [x] validate_current() — invariantes blue-green
- [x] Deteccao + eliminacao de daemons pm2 paralelos
- [x] Matar orphans na :3000 antes de pm2 start
- [x] DIAGNOSTICO.md — runbook para problemas comuns

## v1.5.0 — Fase B Fiscal 📋 Planned
- [ ] B.1 Retencoes na fonte sofridas (registo manual, deduz IRC, Art. 90.º)
- [ ] B.2 Mais-valias / menos-valias de alienacao de activos
- [ ] B.3 Modelo 22 — exportacao dos quadros principais (07, 09, 10)
- [ ] B.4 Validacoes pre-encerramento (checklist antes de fechar exercicio)

## v1.x.x — Optimizacao Docker e DevOps 📋 Planned
- [ ] Criar .dockerignore (node_modules, .git, electron, .env — reduz contexto em 500MB+)
- [ ] Remover node_modules completo do runner (standalone ja inclui deps, copiar so Prisma CLI)
- [ ] Remover --no-cache do update.sh (usar cache Docker, rebuild so da app)
- [ ] Cache Prisma generate separado (COPY prisma antes do COPY . .)
- [ ] BuildKit com --mount=type=cache para npm ci
- [ ] flock nos scripts update para prevenir execucoes concorrentes
- [ ] Abort update se backup falhar
- [ ] git diff para skip inteligente (so codigo = so build, nada mudou = exit)
- [ ] Polling em vez de sleep 30s no update.sh
- [ ] Log rotation para update.log (/etc/logrotate.d/imoveo)
- [ ] Remover update.sh e update-watcher.sh da imagem Docker (scripts do host)
- [ ] Volume shared como read-only onde possivel
- [ ] Sudoers mais restritivo (scoped por comando)
- [ ] Seguranca: pinned base image digest (node:20-alpine@sha256:...)

## v1.6.0 — Electron Desktop 📋 Planned
- [ ] Electron wrapper com PostgreSQL embutido
- [ ] Instalador Windows (.exe NSIS)
- [ ] Instalador macOS (.dmg)
- [ ] Instalador Linux (.AppImage)
- [ ] Auto-updater via GitHub Releases

## v2.0.0 — Multi-empresa 📋 Planned
- [ ] Suporte multi-tenant
- [ ] Isolamento de dados por empresa
- [ ] Gestao de subscriptions
