# Changelog — Imoveo
Todas as alteracoes notaveis a este projecto estao documentadas aqui.
Formato: [Keep a Changelog](https://keepachangelog.com/pt-PT/1.0.0/)

---

## [1.0.0] — 2026-04-06

### Added
- Dashboard principal com vista detalhada/simples, KPIs, graficos e tabela expansivel
- Gestao de imoveis com quartos (fracoes), ocupacao e reordenacao manual
- Centros de custo (Despesas Gerais, Despesas Pessoais) protegidos
- Importacao de CSV e-Fatura (recebidas e emitidas) com deteccao automatica de tipo e periodo
- Deduplicacao de ficheiros e faturas (SHA-256)
- Classificacao automatica por NIF com regras persistentes
- Classificacao batch de multiplas faturas
- Parser CSV com suporte a notas de credito (valores negativos) e documentos anulados (ignorados)
- Lancamentos manuais com multi-mes, retencao na fonte e IVA por dropdown
- Pagina de pendentes com filtro server-side por tipo (receitas/despesas) e pesquisa
- Pagina de faturas classificadas com filtros por data, tipo, imovel, rubrica
- Paginacao server-side em todas as tabelas (25/50/100/200 por pagina)
- Analise financeira completa: rentabilidade por imovel, cash flow, indicadores de risco, previsao IRC
- Custos operacionais: distribuicao por rubrica (donut), evolucao mensal (area chart), ranking
- Previsao IRC: calculo PME detalhado, retencoes na fonte, pagamento por conta
- Calculadora financeira: yield, ROI, DSCR, ponto de equilibrio, portfolio
- Simulador de credito/leasing com Euribor + spread
- Detalhe por imovel com racios, avaliacao automatica e graficos
- Configuracoes fiscais editaveis (derrama, regime PME, taxas IRC)
- Sistema RBAC com 3 perfis (Admin, Gestor, Operador) e 24 permissoes
- Autenticacao NextAuth v5 com JWT
- Regime de acrescimo para receitas (fatura mes N = receita mes N+1)
- Potencial de receita baseado em faturas reais (nao valores actuais dos quartos)
- Taxa de ocupacao real baseada em faturas emitidas e data de entrada no mercado
- Seleccao dinamica de anos disponiveis em todos os filtros
- Docker Compose para desenvolvimento e producao
- Ficheiros Electron para app desktop (main, pg-manager, server-manager, tray, preload)
- Guia de deploy completo (DEPLOY.md)

### Database
- Schema Prisma com 11 modelos, 13 enums
- Tabela Configuracao para parametros fiscais
- Tabela Fracao com data de entrada no mercado
- Campo ordem nos imoveis para reordenacao manual
- Campos valorPatrimonial e areaMt2 nos imoveis
- Campos retencaoFonte e valorRetencao nos lancamentos manuais

### Infrastructure
- Next.js 16 com Turbopack
- Prisma 7 com adapter PrismaPg
- Tailwind CSS v4 com cores da marca Imoveo
- Docker Compose (dev: PostgreSQL na porta 5433)
- Docker Compose producao (app + PostgreSQL + Nginx)
- Proxy (Next.js 16) em vez de middleware (deprecated)
- GitHub Actions CI pipeline
