import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { writeFileSync, existsSync } from 'fs'
import { join } from 'path'
import { execSync } from 'child_process'
import { debugLog, debugError } from '@/lib/debug-logger'

const isWindows = process.platform === 'win32'
const DB_URL = process.env.DATABASE_URL || ''

// Encontrar psql — pode estar em diferentes paths
function findPsql(): string {
  const paths = ['/usr/bin/psql', '/usr/local/bin/psql', '/usr/lib/postgresql/16/bin/psql', '/usr/lib/postgresql/17/bin/psql']
  for (const p of paths) {
    if (existsSync(p)) return p
  }
  return 'psql' // fallback para PATH
}

const PSQL = isWindows ? 'psql' : findPsql()

function runDropSchema(): void {
  const url = new URL(DB_URL)
  const host = url.hostname
  const port = url.port || '5432'
  const user = url.username
  const password = url.password
  const database = url.pathname.replace('/', '')

  const dropSQL = "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO public;"

  debugLog('backup/upload', `DROP SCHEMA — psql: ${PSQL}, host: ${host}, port: ${port}, db: ${database}`)

  if (isWindows) {
    const containerName = 'imoveo-postgres-1'
    execSync(
      `docker exec -e PGPASSWORD=${password} ${containerName} psql -U ${user} ${database} -c "${dropSQL}"`,
      { timeout: 30000 }
    )
  } else {
    execSync(
      `PGPASSWORD='${password}' ${PSQL} -h ${host} -p ${port} -U ${user} ${database} -c "${dropSQL}"`,
      { timeout: 30000 }
    )
  }
  debugLog('backup/upload', 'DROP SCHEMA concluido')
}

export async function POST(req: Request) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const formData = await req.formData()
    const file = formData.get('file') as File | null

    if (!file) return Response.json({ error: 'Ficheiro obrigatorio' }, { status: 400 })

    const filename = file.name
    if (!filename.endsWith('.sql') && !filename.endsWith('.sql.gz')) {
      return Response.json({ error: 'Formato invalido. Use .sql ou .sql.gz' }, { status: 400 })
    }

    const buffer = Buffer.from(await file.arrayBuffer())
    const tmpDir = isWindows ? join(process.cwd(), 'backups') : '/tmp'
    const tmpPath = join(tmpDir, `imoveo_upload_${Date.now()}_${filename}`)
    writeFileSync(tmpPath, buffer)

    const url = new URL(DB_URL)
    const host = url.hostname
    const port = url.port || '5432'
    const user = url.username
    const password = url.password
    const database = url.pathname.replace('/', '')

    const isGzip = filename.endsWith('.gz')

    // Limpar schema antes de importar para evitar conflitos
    debugLog('backup/upload', `A importar ${filename} (${buffer.length} bytes, gzip: ${isGzip})`)
    runDropSchema()

    if (isWindows) {
      const containerName = 'imoveo-postgres-1'
      if (isGzip) {
        execSync(`docker cp "${tmpPath}" ${containerName}:/tmp/restore.sql.gz`, { timeout: 30000 })
        execSync(`docker exec ${containerName} bash -c "gunzip -c /tmp/restore.sql.gz | PGPASSWORD='${password}' psql -U ${user} ${database}"`, { timeout: 120000 })
      } else {
        execSync(`docker cp "${tmpPath}" ${containerName}:/tmp/restore.sql`, { timeout: 30000 })
        execSync(`docker exec -e PGPASSWORD=${password} ${containerName} psql -U ${user} ${database} -f /tmp/restore.sql`, { timeout: 120000 })
      }
    } else {
      if (isGzip) {
        execSync(`gunzip -c "${tmpPath}" | PGPASSWORD='${password}' ${PSQL} -h ${host} -p ${port} -U ${user} ${database}`, { timeout: 120000 })
      } else {
        execSync(`PGPASSWORD='${password}' ${PSQL} -h ${host} -p ${port} -U ${user} ${database} < "${tmpPath}"`, { timeout: 120000 })
      }
    }

    try { if (!isWindows) execSync(`rm -f "${tmpPath}"`) } catch { /* ignore */ }

    debugLog('backup/upload', `Backup importado: ${filename}`)
    return Response.json({ message: `Backup importado com sucesso: ${filename}` })
  } catch (e) {
    debugError('backup/upload', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao importar backup', details: String(e) }, { status: 500 })
  }
}
