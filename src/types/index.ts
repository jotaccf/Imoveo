import type { Role } from '@/generated/prisma/enums'

export interface SessionUser {
  id: string
  nome: string
  email: string
  role: Role
}

export interface ApiResponse<T = unknown> {
  data?: T
  error?: string
  message?: string
}

export interface RelatorioImportacao {
  ficheiroDuplicado: boolean
  importacaoId?: string
  totalFaturas: number
  novas: number
  duplicadas: number
  pendentes: number
  periodo?: string
  tipoFicheiro?: 'EMITIDAS' | 'RECEBIDAS'
}

export interface ResultadoImovel {
  rubricaId: string
  rubricaNome: string
  rubricaTipo: 'RECEITA' | 'GASTO'
  valores: Record<string, number>
  total: number
}

export interface ResultadosResponse {
  imoveis: { id: string; nome: string; codigo: string }[]
  linhas: ResultadoImovel[]
  totaisGastos: Record<string, number>
  totaisReceita: Record<string, number>
  resultadoLiquido: Record<string, number>
  margens: Record<string, number>
  totalGeral: number
  receitaGeral: number
  resultadoGeral: number
}
