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

## v1.1.0 — Melhorias UX e Reporting 📋 Planned
- [ ] Comparacao YoY (ano vs ano anterior)
- [ ] Alertas automaticos por threshold (yield, ocupacao, racio)
- [ ] Gestao de contratos de arrendamento (inicio, fim, valor, renovacao)
- [ ] Dashboard de gestao de contratos (expiracoes, renovacoes)

## v1.2.0 — Electron Desktop 📋 Planned
- [ ] Electron wrapper com PostgreSQL embutido
- [ ] Instalador Windows (.exe NSIS)
- [ ] Instalador macOS (.dmg)
- [ ] Instalador Linux (.AppImage)
- [ ] Auto-updater via GitHub Releases

## v2.0.0 — Multi-empresa 📋 Planned
- [ ] Suporte multi-tenant
- [ ] Isolamento de dados por empresa
- [ ] Gestao de subscriptions
