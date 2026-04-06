import { NextRequest } from 'next/server'
import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { execSync } from 'child_process'
import { readdirSync, statSync, unlinkSync } from 'fs'
import { join } from 'path'

const BACKUP_DIR = process.env.BACKUP_DIR || '/opt/backups/imoveo'
const DB_URL = process.env.DATABASE_URL || ''

function getBackupList() {
  try {
    const files = readdirSync(BACKUP_DIR)
      .filter((f) => f.endsWith('.sql.gz') || f.endsWith('.sql'))
      .map((f) => {
        const fullPath = join(BACKUP_DIR, f)
        const stats = statSync(fullPath)
        return {
          filename: f,
          size: stats.size,
          sizeFormatted: stats.size > 1048576
            ? `${(stats.size / 1048576).toFixed(1)} MB`
            : `${(stats.size / 1024).toFixed(0)} KB`,
          createdAt: stats.mtime.toISOString(),
        }
      })
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
    return files
  } catch {
    return []
  }
}

// GET — listar backups
export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:ver')

    const backups = getBackupList()
    return Response.json({ data: backups })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

// POST — criar backup
export async function POST(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    // Parse DATABASE_URL to get connection details
    const url = new URL(DB_URL)
    const host = url.hostname
    const port = url.port || '5432'
    const user = url.username
    const password = url.password
    const database = url.pathname.replace('/', '')

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').replace('T', '_').slice(0, 19)
    const filename = `imoveo_manual_${timestamp}.sql`
    const filepath = join(BACKUP_DIR, filename)

    // Execute pg_dump
    execSync(
      `PGPASSWORD='${password}' pg_dump -h ${host} -p ${port} -U ${user} ${database} > ${filepath}`,
      { timeout: 60000 }
    )

    // Compress
    execSync(`gzip ${filepath}`, { timeout: 30000 })

    const backups = getBackupList()
    return Response.json({
      data: backups,
      message: `Backup criado: ${filename}.gz`,
    }, { status: 201 })
  } catch (e) {
    console.error('[backup] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao criar backup', details: String(e) }, { status: 500 })
  }
}

// DELETE — eliminar backup
export async function DELETE(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const { filename } = await req.json()
    if (!filename || filename.includes('..') || filename.includes('/')) {
      return Response.json({ error: 'Filename invalido' }, { status: 400 })
    }

    const filepath = join(BACKUP_DIR, filename)
    unlinkSync(filepath)

    const backups = getBackupList()
    return Response.json({ data: backups, message: 'Backup eliminado' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao eliminar backup' }, { status: 500 })
  }
}

// PUT — restaurar backup
export async function PUT(req: NextRequest) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const { filename } = await req.json()
    if (!filename || filename.includes('..') || filename.includes('/')) {
      return Response.json({ error: 'Filename invalido' }, { status: 400 })
    }

    const url = new URL(DB_URL)
    const host = url.hostname
    const port = url.port || '5432'
    const user = url.username
    const password = url.password
    const database = url.pathname.replace('/', '')

    const filepath = join(BACKUP_DIR, filename)
    const isGzipped = filename.endsWith('.gz')

    if (isGzipped) {
      execSync(
        `gunzip -c ${filepath} | PGPASSWORD='${password}' psql -h ${host} -p ${port} -U ${user} ${database}`,
        { timeout: 120000 }
      )
    } else {
      execSync(
        `PGPASSWORD='${password}' psql -h ${host} -p ${port} -U ${user} ${database} < ${filepath}`,
        { timeout: 120000 }
      )
    }

    return Response.json({ message: `Backup restaurado: ${filename}` })
  } catch (e) {
    console.error('[restore] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao restaurar backup', details: String(e) }, { status: 500 })
  }
}
