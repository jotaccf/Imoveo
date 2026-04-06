# Imoveo — Development Log

## SESSAO 1 — 2026-04-01

### O que foi feito
- Projecto base criado com Next.js 16, Prisma 7, NextAuth v5 beta
- Todas as 10 fases do IMOVEO_BUILD.md implementadas

### Decisoes tecnicas
- Prisma 7 usa adapter PrismaPg (sem URL no schema)
- Next.js 16: proxy.ts em vez de middleware.ts
- Docker PostgreSQL na porta 5433 (5432 ocupada localmente)
- Jest mocks para Prisma client (ESM/import.meta incompativel)

---

## SESSAO 2 — 2026-04-01 a 2026-04-06

### O que foi feito
- CSV parser para e-Fatura (recebidas + emitidas) com deteccao automatica
- Notas de credito com valores negativos, documentos anulados ignorados
- Centros de custo (CC-GERAL, CC-PESSOAL) protegidos
- Sistema de quartos (fracoes) com ocupacao e data de entrada no mercado
- Classificacao automatica por NIF com propagacao para pendentes existentes
- Classificacao batch de multiplas faturas
- Lancamentos manuais: multi-mes, retencao na fonte, IVA por dropdown
- Paginacao server-side nas 3 tabelas principais
- Dashboard redesenhado: vista detalhada com graficos, KPIs, tabela expansivel
- Analise financeira: 8 categorias de KPIs, rentabilidade por imovel
- Custos operacionais: donut chart, area chart, ranking
- Previsao IRC: calculo PME, retencoes, pagamento por conta
- Calculadora financeira: yield, DSCR, break-even, portfolio, simulador credito
- Detalhe por imovel com racios e avaliacao automatica
- Configuracoes fiscais editaveis
- Regime de acrescimo (receita mes N+1) com cross-year correcto
- Potencial baseado em receita real, ocupacao por faturas emitidas
- Anos disponiveis detectados automaticamente
- Reordenacao manual de imoveis (setas up/down)
- Campo de pesquisa server-side nos pendentes

### Decisoes tecnicas
- Receitas: regime de acrescimo (fatura Dez = receita Jan seguinte)
- Fatura Dez do ano actual excluida do ano (pertence ao seguinte)
- Fatura Dez do ano anterior incluida em Janeiro
- Potencial calculado por media de faturas reais (nao valor actual do quarto)
- Ocupacao: faturas emitidas / meses disponiveis desde entrada no mercado
- nifEmitente nas emitidas: "EMITIDA" (serie nao e NIF valido)
- Paginacao server-side com totais agregados no servidor

### Alteracoes ao schema
- Fracao: dataEntradaMercado, modelo completo
- Imovel: valorPatrimonial, areaMt2, ordem
- LancamentoManual: retencaoFonte, valorRetencao
- Configuracao: tabela de parametros fiscais
- FaturaClassificacao: fracaoId opcional
- NifImovelMap: fracaoId opcional

### Estado actual
- ✅ Todas as funcionalidades core implementadas
- ✅ Build compila sem erros
- ✅ Testes passam (67+)
- 📋 Pendente: contratos de arrendamento, exportacao PDF, alertas
