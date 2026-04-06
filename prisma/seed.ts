import { PrismaClient } from '../src/generated/prisma/client.js'
import { PrismaPg } from '@prisma/adapter-pg'
import { hashSync } from 'bcryptjs'
import 'dotenv/config'

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! })
const prisma = new PrismaClient({ adapter })

async function main() {
  if (process.env.SEED_IF_EMPTY === 'true') {
    const count = await prisma.utilizador.count()
    if (count > 0) {
      console.log('Seed ignorado — BD ja tem dados')
      return
    }
  }

  const passwordHash = hashSync('Imoveo2024!', 12)

  // Utilizadores
  await prisma.utilizador.upsert({
    where: { email: 'admin@imoveo.local' },
    update: {},
    create: { nome: 'Administrador', email: 'admin@imoveo.local', passwordHash, role: 'ADMIN' },
  })
  await prisma.utilizador.upsert({
    where: { email: 'gestor@imoveo.local' },
    update: {},
    create: { nome: 'Gestor', email: 'gestor@imoveo.local', passwordHash, role: 'GESTOR' },
  })
  await prisma.utilizador.upsert({
    where: { email: 'operador@imoveo.local' },
    update: {},
    create: { nome: 'Operador', email: 'operador@imoveo.local', passwordHash, role: 'OPERADOR' },
  })

  // Rubricas
  const rubricas = [
    { codigo: 'REC', nome: 'Receita (Rendas)', tipo: 'RECEITA' as const, ordem: 0 },
    { codigo: 'RJB', nome: 'Receita (Juros Bancarios)', tipo: 'RECEITA' as const, ordem: -4 },
    { codigo: 'RSV', nome: 'Receita (Prestacao Servicos)', tipo: 'RECEITA' as const, ordem: -3 },
    { codigo: 'RDV', nome: 'Receita (Outras Receitas)', tipo: 'RECEITA' as const, ordem: -2 },
    { codigo: 'CMB', nome: 'Combustivel', tipo: 'GASTO' as const, ordem: 1 },
    { codigo: 'CAF', nome: 'Compras de Ativo Fixo', tipo: 'GASTO' as const, ordem: 2 },
    { codigo: 'COM', nome: 'Comunicacoes', tipo: 'GASTO' as const, ordem: 3 },
    { codigo: 'CRP', nome: 'Conservacao e Reparacao', tipo: 'GASTO' as const, ordem: 4 },
    { codigo: 'DES', nome: 'Deslocacoes e Estadas', tipo: 'GASTO' as const, ordem: 5 },
    { codigo: 'AGU', nome: 'Gastos de Agua', tipo: 'GASTO' as const, ordem: 6 },
    { codigo: 'ELE', nome: 'Gastos de Electricidade', tipo: 'GASTO' as const, ordem: 7 },
    { codigo: 'HON', nome: 'Honorarios e Comissoes', tipo: 'GASTO' as const, ordem: 8 },
    { codigo: 'LHC', nome: 'Limpeza Higiene e Conforto', tipo: 'GASTO' as const, ordem: 9 },
    { codigo: 'MAT', nome: 'Material de Escritorio', tipo: 'GASTO' as const, ordem: 10 },
    { codigo: 'SEG', nome: 'Seguros', tipo: 'GASTO' as const, ordem: 11 },
    { codigo: 'GAS', nome: 'Gastos de Gas', tipo: 'GASTO' as const, ordem: 12 },
    { codigo: 'RDA', nome: 'Rendas e Alugueres', tipo: 'GASTO' as const, ordem: 13 },
    { codigo: 'OUT', nome: 'Outros Gastos', tipo: 'GASTO' as const, ordem: 14 },
  ]

  for (const r of rubricas) {
    await prisma.rubrica.upsert({
      where: { codigo: r.codigo },
      update: {},
      create: r,
    })
  }

  // Centros de custo gerais (nao sao imoveis fisicos)
  const centrosCusto = [
    { codigo: 'CC-GERAL', nome: 'Despesas Gerais', tipo: 'GERAL' as const, localizacao: 'Administracao', estado: 'ACTIVO' as const },
    { codigo: 'CC-PESSOAL', nome: 'Despesas Pessoais', tipo: 'PESSOAL' as const, localizacao: 'Pessoal', estado: 'ACTIVO' as const },
  ]

  for (const cc of centrosCusto) {
    await prisma.imovel.upsert({
      where: { codigo: cc.codigo },
      update: {},
      create: cc,
    })
  }

  // Imoveis de exemplo
  const imoveis = [
    { codigo: 'APT-001', nome: 'Apt. Chiado 3 Dto', tipo: 'APARTAMENTO' as const, localizacao: 'Lisboa', estado: 'ACTIVO' as const },
    { codigo: 'MOR-001', nome: 'Moradia Cascais', tipo: 'MORADIA' as const, localizacao: 'Cascais', estado: 'ACTIVO' as const },
    { codigo: 'LOJ-001', nome: 'Loja Setubal', tipo: 'LOJA' as const, localizacao: 'Setubal', estado: 'VAGO' as const },
  ]

  for (const i of imoveis) {
    await prisma.imovel.upsert({
      where: { codigo: i.codigo },
      update: {},
      create: i,
    })
  }

  // Configuracoes por defeito
  const configs = [
    { chave: 'derrama_municipal', valor: '1.5' },
    { chave: 'regime_pme', valor: 'true' },
    { chave: 'taxa_irc_pme', valor: '17' },
    { chave: 'taxa_irc_normal', valor: '21' },
    { chave: 'limite_pme', valor: '50000' },
    { chave: 'taxa_retencao_rendas', valor: '25' },
    { chave: 'exercicio_inicio', valor: '01' },
    { chave: 'exercicio_fim', valor: '12' },
  ]

  for (const c of configs) {
    await prisma.configuracao.upsert({
      where: { chave: c.chave },
      update: {},
      create: c,
    })
  }

  console.log('Seed concluido com sucesso')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
