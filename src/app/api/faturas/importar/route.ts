import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { processarImportacao } from '@/lib/deduplicacao'

export async function POST(req: Request) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'xml:importar')

    const formData = await req.formData()
    const file = formData.get('file') as File | null

    if (!file) {
      return Response.json({ error: 'Ficheiro obrigatorio' }, { status: 400 })
    }

    const buffer = Buffer.from(await file.arrayBuffer())
    const resultado = await processarImportacao(buffer, file.name)

    return Response.json({ data: resultado })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao processar ficheiro' }, { status: 500 })
  }
}
