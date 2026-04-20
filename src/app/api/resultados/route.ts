import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import type { ResultadosResponse, ResultadoImovel } from '@/types'

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const { searchParams } = req.nextUrl
    const ano = searchParams.get('ano') ? Number(searchParams.get('ano')) : new Date().getFullYear()
    const trimestre = searchParams.get('trimestre') ? Number(searchParams.get('trimestre')) : null
    const mes = searchParams.get('mes') ? Number(searchParams.get('mes')) : null

    let dateStart: Date, dateEnd: Date
    if (mes) {
      dateStart = new Date(ano, mes - 1, 1)
      dateEnd = new Date(ano, mes, 1)
    } else if (trimestre) {
      dateStart = new Date(ano, (trimestre - 1) * 3, 1)
      dateEnd = new Date(ano, trimestre * 3, 1)
    } else {
      dateStart = new Date(ano, 0, 1)
      dateEnd = new Date(ano + 1, 0, 1)
    }

    // Get active properties
    const imoveis = await prisma.imovel.findMany({
      where: { ativo: true },
      select: { id: true, nome: true, codigo: true },
      orderBy: { codigo: 'asc' },
    })

    const rubricas = await prisma.rubrica.findMany({ orderBy: { ordem: 'asc' } })

    // Get classified invoices — expanded range for accrual basis (Dec year-1 for Jan revenue)
    const dateStartExpanded = new Date(ano - 1, 11, 1)
    const faturas = await prisma.faturaClassificacao.findMany({
      where: {
        confirmado: true,
        fatura: { dataFatura: { gte: dateStartExpanded, lt: dateEnd } },
      },
      include: { fatura: true, rubrica: true },
    })

    // Get manual entries — same expanded range
    const lancamentos = await prisma.lancamentoManual.findMany({
      where: { dataDoc: { gte: dateStartExpanded, lt: dateEnd } },
    })

    // Helper: should this record be included for the selected year?
    function includeRecord(dataDoc: Date, isReceita: boolean): boolean {
      const recAno = dataDoc.getFullYear()
      const recMes = dataDoc.getMonth()
      if (isReceita) {
        // Accrual: revenue belongs to month+1
        // Dec of this year → next year (exclude)
        if (recAno === ano && recMes === 11) return false
        // Dec of prev year → Jan this year (include)
        if (recAno === ano - 1 && recMes === 11) return true
        // Normal months of this year
        return recAno === ano
      } else {
        // Expenses: same year only
        return recAno === ano
      }
    }

    // Build pivot table
    const linhas: ResultadoImovel[] = rubricas.map((r) => {
      const valores: Record<string, number> = {}
      let total = 0
      const isReceita = r.tipo === 'RECEITA'

      for (const im of imoveis) {
        let soma = 0

        // Sum from classified invoices
        for (const fc of faturas) {
          if (fc.rubricaId === r.id && fc.imovelId === im.id) {
            if (!includeRecord(new Date(fc.fatura.dataFatura), isReceita)) continue
            soma += fc.valorAtribuido ? Number(fc.valorAtribuido) : Number(fc.fatura.totalComIva)
          }
        }

        // Sum from manual entries
        for (const lm of lancamentos) {
          if (lm.rubricaId === r.id && lm.imovelId === im.id) {
            if (!includeRecord(new Date(lm.dataDoc), isReceita)) continue
            soma += Number(lm.totalComIva)
          }
        }

        valores[im.id] = soma
        total += soma
      }

      return {
        rubricaId: r.id,
        rubricaNome: r.nome,
        rubricaTipo: r.tipo as 'RECEITA' | 'GASTO',
        valores,
        total,
      }
    })

    // Calculate totals
    const totaisGastos: Record<string, number> = {}
    const totaisReceita: Record<string, number> = {}
    const resultadoLiquido: Record<string, number> = {}
    const margens: Record<string, number> = {}
    let totalGeral = 0, receitaGeral = 0, resultadoGeral = 0

    for (const im of imoveis) {
      totaisGastos[im.id] = 0
      totaisReceita[im.id] = 0

      for (const l of linhas) {
        if (l.rubricaTipo === 'RECEITA') totaisReceita[im.id] += l.valores[im.id] || 0
        else totaisGastos[im.id] += l.valores[im.id] || 0
      }

      resultadoLiquido[im.id] = totaisReceita[im.id] - totaisGastos[im.id]
      margens[im.id] = totaisReceita[im.id] > 0
        ? (resultadoLiquido[im.id] / totaisReceita[im.id]) * 100
        : 0

      totalGeral += totaisGastos[im.id]
      receitaGeral += totaisReceita[im.id]
    }

    resultadoGeral = receitaGeral - totalGeral

    const response: ResultadosResponse = {
      imoveis,
      linhas: linhas.filter((l) => l.total !== 0),
      totaisGastos,
      totaisReceita,
      resultadoLiquido,
      margens,
      totalGeral,
      receitaGeral,
      resultadoGeral,
    }

    return Response.json({ data: response })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
