import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { writeFileSync } from 'fs'
import { join } from 'path'
import { execSync } from 'child_process'

const DB_URL = process.env.DATABASE_URL || ''

export async function POST(req: Request) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const formData = await req.formData()
    const file = formData.get('file') as File | null

    if (!file) {
      return Response.json({ error: 'Ficheiro obrigatorio' }, { status: 400 })
    }

    const filename = file.name
    if (!filename.endsWith('.sql') && !filename.endsWith('.sql.gz')) {
      return Response.json({ error: 'Formato invalido. Use .sql ou .sql.gz' }, { status: 400 })
    }

    // Guardar ficheiro temporario
    const buffer = Buffer.from(await file.arrayBuffer())
    const tmpPath = join('/tmp', `imoveo_upload_${Date.now()}_${filename}`)
    writeFileSync(tmpPath, buffer)

    // Parse DB URL
    const url = new URL(DB_URL)
    const host = url.hostname
    const port = url.port || '5432'
    const user = url.username
    const password = url.password
    const database = url.pathname.replace('/', '')

    // Restaurar
    const isGzip = filename.endsWith('.gz')
    if (isGzip) {
      execSync(
        `gunzip -c ${tmpPath} | PGPASSWORD='${password}' psql -h ${host} -p ${port} -U ${user} ${database}`,
        { timeout: 120000 }
      )
    } else {
      execSync(
        `PGPASSWORD='${password}' psql -h ${host} -p ${port} -U ${user} ${database} < ${tmpPath}`,
        { timeout: 120000 }
      )
    }

    // Limpar temporario
    try { execSync(`rm -f ${tmpPath}`) } catch { /* ignore */ }

    return Response.json({
      message: `Backup importado com sucesso: ${filename}`,
    })
  } catch (e) {
    console.error('[backup/upload] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao importar backup', details: String(e) }, { status: 500 })
  }
}
