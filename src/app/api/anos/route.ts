import { prisma } from '@/lib/prisma'

export async function GET() {
  try {
    // Get distinct years from faturas and lancamentos
    const [faturaYears, lancamentoYears] = await Promise.all([
      prisma.$queryRawUnsafe<{ ano: number }[]>(
        `SELECT DISTINCT EXTRACT(YEAR FROM "dataFatura")::int AS ano FROM faturas ORDER BY ano DESC`
      ),
      prisma.$queryRawUnsafe<{ ano: number }[]>(
        `SELECT DISTINCT EXTRACT(YEAR FROM "dataDoc")::int AS ano FROM lancamentos_manuais ORDER BY ano DESC`
      ),
    ])

    const anos = new Set<number>()
    anos.add(new Date().getFullYear()) // sempre incluir ano actual
    for (const r of faturaYears) anos.add(r.ano)
    for (const r of lancamentoYears) anos.add(r.ano)

    return Response.json({ data: Array.from(anos).sort((a, b) => b - a) })
  } catch (e) {
    console.error('[/api/anos] Error:', e)
    return Response.json({ data: [new Date().getFullYear()] })
  }
}
