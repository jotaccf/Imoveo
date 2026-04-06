import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { loadAnaliseData, type GlobalAnalise, type ImovelAnalise, type MonthData } from '@/lib/analise-data'

// ---------- helpers ----------

function varPct(atual: number, anterior: number): number {
  if (anterior === 0) return atual === 0 ? 0 : 100
  return ((atual - anterior) / Math.abs(anterior)) * 100
}

function globalDelta(atual: GlobalAnalise, anterior: GlobalAnalise) {
  return {
    receitaTotal: { atual: atual.receitaTotal, anterior: anterior.receitaTotal, delta: atual.receitaTotal - anterior.receitaTotal, pct: varPct(atual.receitaTotal, anterior.receitaTotal) },
    custoTotal: { atual: atual.custoTotal, anterior: anterior.custoTotal, delta: atual.custoTotal - anterior.custoTotal, pct: varPct(atual.custoTotal, anterior.custoTotal) },
    resultadoLiquido: { atual: atual.resultadoLiquido, anterior: anterior.resultadoLiquido, delta: atual.resultadoLiquido - anterior.resultadoLiquido, pct: varPct(atual.resultadoLiquido, anterior.resultadoLiquido) },
    margemBrutaPct: { atual: atual.margemBrutaPct, anterior: anterior.margemBrutaPct, delta: atual.margemBrutaPct - anterior.margemBrutaPct },
    ratiCobertura: { atual: atual.ratiCobertura, anterior: anterior.ratiCobertura, delta: atual.ratiCobertura - anterior.ratiCobertura },
  }
}

function imoveisDelta(atuais: ImovelAnalise[], anteriores: ImovelAnalise[]) {
  const anteriorMap = new Map(anteriores.map((im) => [im.id, im]))
  return atuais.map((im) => {
    const ant = anteriorMap.get(im.id)
    return {
      id: im.id,
      nome: im.nome,
      receitaAtual: im.receita,
      receitaAnterior: ant?.receita ?? 0,
      receitaVar: varPct(im.receita, ant?.receita ?? 0),
      resultadoAtual: im.resultadoLiquido,
      resultadoAnterior: ant?.resultadoLiquido ?? 0,
      resultadoVar: varPct(im.resultadoLiquido, ant?.resultadoLiquido ?? 0),
    }
  })
}

function evolucaoDelta(atual: MonthData[], anterior: MonthData[]) {
  return atual.map((m, i) => {
    const ant = anterior[i] || { receita: 0, custos: 0 }
    return {
      mes: m.mes,
      receitaAtual: m.receita,
      receitaAnterior: ant.receita,
      receitaVar: varPct(m.receita, ant.receita),
      custosAtual: m.custos,
      custosAnterior: ant.custos,
      custosVar: varPct(m.custos, ant.custos),
    }
  })
}

// ---------- handler ----------

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:ver')

    const { searchParams } = req.nextUrl
    const ano = searchParams.get('ano') ? Number(searchParams.get('ano')) : new Date().getFullYear()

    const [dataAtual, dataAnterior] = await Promise.all([
      loadAnaliseData(ano),
      loadAnaliseData(ano - 1),
    ])

    return Response.json({
      data: {
        ano,
        anoAnterior: ano - 1,
        global: globalDelta(dataAtual.global, dataAnterior.global),
        imoveis: imoveisDelta(dataAtual.imoveis, dataAnterior.imoveis),
        evolucaoMensal: evolucaoDelta(dataAtual.evolucaoMensal, dataAnterior.evolucaoMensal),
        ircAtual: dataAtual.irc.ircTotal,
        ircAnterior: dataAnterior.irc.ircTotal,
        ircVar: varPct(dataAtual.irc.ircTotal, dataAnterior.irc.ircTotal),
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
