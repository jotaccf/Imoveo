import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { readFileSync, existsSync, mkdirSync } from 'fs'
import { join } from 'path'
import { execSync } from 'child_process'

const isWindows = process.platform === 'win32'
const BACKUP_DIR = process.env.BACKUP_DIR || (isWindows ? join(process.cwd(), 'backups') : '/opt/backups/imoveo')
const DB_URL = process.env.DATABASE_URL || ''

function findBin(name: string): string {
  const paths = [`/usr/bin/${name}`, `/usr/local/bin/${name}`, `/usr/lib/postgresql/16/bin/${name}`, `/usr/lib/postgresql/17/bin/${name}`]
  for (const p of paths) { if (existsSync(p)) return p }
  return name
}
const PG_DUMP = isWindows ? 'pg_dump' : findBin('pg_dump')

try { mkdirSync(BACKUP_DIR, { recursive: true }) } catch { /* ignore */ }

export async function GET(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const { searchParams } = req.nextUrl
    const filename = searchParams.get('file')

    let filepath: string
    let downloadName: string

    if (filename) {
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        return Response.json({ error: 'Filename invalido' }, { status: 400 })
      }
      filepath = join(BACKUP_DIR, filename)
      downloadName = filename
    } else {
      // Criar backup fresh
      const url = new URL(DB_URL)
      const host = url.hostname
      const port = url.port || '5432'
      const user = url.username
      const password = url.password
      const database = url.pathname.replace('/', '')

      const timestamp = new Date().toISOString().replace(/[:.]/g, '-').replace('T', '_').slice(0, 19)
      downloadName = `imoveo_export_${timestamp}.sql`
      filepath = join(BACKUP_DIR, downloadName)

      if (isWindows) {
        const containerName = 'imoveo-postgres-1'
        execSync(
          `docker exec -e PGPASSWORD=${password} ${containerName} pg_dump -U ${user} ${database} > "${filepath}"`,
          { timeout: 120000, shell: 'cmd.exe' }
        )
      } else {
        execSync(
          `PGPASSWORD='${password}' ${PG_DUMP} -h ${host} -p ${port} -U ${user} ${database} > "${filepath}"`,
          { timeout: 120000 }
        )
      }
    }

    if (!existsSync(filepath)) {
      return Response.json({ error: 'Ficheiro nao encontrado' }, { status: 404 })
    }

    const buffer = readFileSync(filepath)
    const isGzip = downloadName.endsWith('.gz')

    return new Response(buffer, {
      headers: {
        'Content-Type': isGzip ? 'application/gzip' : 'application/sql',
        'Content-Disposition': `attachment; filename="${downloadName}"`,
        'Content-Length': String(buffer.length),
      },
    })
  } catch (e) {
    console.error('[backup/download] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao exportar backup' }, { status: 500 })
  }
}
