import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import Papa from 'papaparse'

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'resultados:exportar')

    // Fetch results from our own API
    const { searchParams } = req.nextUrl
    const url = new URL('/api/resultados', req.url)
    searchParams.forEach((value, key) => url.searchParams.set(key, value))

    const res = await fetch(url, { headers: { cookie: req.headers.get('cookie') || '' } })
    const { data } = await res.json()

    if (!data) return Response.json({ error: 'Sem dados' }, { status: 404 })

    // Build CSV rows
    const rows: Record<string, unknown>[] = []
    const header = ['Rubrica', 'Tipo', ...data.imoveis.map((i: { codigo: string }) => i.codigo), 'TOTAL']

    for (const linha of data.linhas) {
      const row: Record<string, unknown> = {
        'Rubrica': linha.rubricaNome,
        'Tipo': linha.rubricaTipo,
      }
      for (const im of data.imoveis) {
        row[im.codigo] = linha.valores[im.id] || 0
      }
      row['TOTAL'] = linha.total
      rows.push(row)
    }

    const csv = Papa.unparse(rows, { columns: header })

    return new Response(csv, {
      headers: {
        'Content-Type': 'text/csv; charset=utf-8',
        'Content-Disposition': `attachment; filename="resultados.csv"`,
      },
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
