import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { prisma } from '@/lib/prisma'
import { requirePermission, type Role } from '@/lib/permissions'
import Papa from 'papaparse'

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'faturas:exportar')

    const { searchParams } = req.nextUrl
    const periodo = searchParams.get('periodo')

    const where: Record<string, unknown> = { classificacoes: { some: { confirmado: true } } }
    if (periodo) {
      const [year, month] = periodo.split('-').map(Number)
      const start = new Date(year, (month || 1) - 1, 1)
      const end = month ? new Date(year, month, 1) : new Date(year + 1, 0, 1)
      where.dataFatura = { gte: start, lt: end }
    }

    const faturas = await prisma.fatura.findMany({
      where,
      include: { classificacoes: { where: { confirmado: true }, include: { imovel: true, rubrica: true } } },
      orderBy: { dataFatura: 'asc' },
    })

    // Uma linha por classificacao (suporta splits)
    const rows: Record<string, unknown>[] = []
    for (const f of faturas) {
      for (const c of f.classificacoes) {
        rows.push({
          'NIF Emitente': f.nifEmitente,
          'Nome Emitente': f.nomeEmitente || '',
          'Serie': f.serieDoc,
          'Numero': f.numeroDoc,
          'Data': f.dataFatura.toISOString().split('T')[0],
          'Valor s/ IVA': Number(f.totalSemIva),
          'IVA': Number(f.totalIva),
          'Total c/ IVA': c.valorAtribuido ? Number(c.valorAtribuido) : Number(f.totalComIva),
          'Imovel': c.imovel.nome,
          'Rubrica': c.rubrica.nome,
        })
      }
    }

    const csv = Papa.unparse(rows)

    return new Response(csv, {
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': `attachment; filename="faturas_${periodo || 'todas'}.csv"`,
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
