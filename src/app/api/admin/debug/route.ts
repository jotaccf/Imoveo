import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { readFileSync, existsSync, statSync } from 'fs'
import { join } from 'path'
import { execSync } from 'child_process'

const isWindows = process.platform === 'win32'

function safe(fn: () => string): string {
  try { return fn() } catch (e) { return `ERRO: ${e}` }
}

function readFileSafe(path: string, tail = 50): string {
  try {
    if (!existsSync(path)) return `[ficheiro nao encontrado: ${path}]`
    const content = readFileSync(path, 'utf-8')
    const lines = content.split('\n')
    return lines.slice(-tail).join('\n')
  } catch (e) { return `ERRO: ${e}` }
}

function execSafe(cmd: string, timeout = 5000): string {
  try {
    return execSync(cmd, { timeout, encoding: 'utf-8' }).trim()
  } catch (e) { return `ERRO: ${e}` }
}

export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const appDir = process.cwd()

    // Versao
    const version = safe(() => readFileSync(join(appDir, 'VERSION'), 'utf-8').trim())

    // Git info
    const gitCommit = execSafe('git rev-parse --short HEAD')
    const gitBranch = execSafe('git rev-parse --abbrev-ref HEAD')
    const gitLog = execSafe('git log --oneline -10')
    const gitStatus = execSafe('git status --short')

    // Uptime do processo Node
    const uptimeSeconds = Math.floor(process.uptime())
    const uptimeFormatted = `${Math.floor(uptimeSeconds / 3600)}h ${Math.floor((uptimeSeconds % 3600) / 60)}m ${uptimeSeconds % 60}s`

    // Sistema
    const platform = process.platform
    const nodeVersion = process.version
    const memoryUsage = process.memoryUsage()
    const memoryMB = {
      rss: (memoryUsage.rss / 1024 / 1024).toFixed(1),
      heapUsed: (memoryUsage.heapUsed / 1024 / 1024).toFixed(1),
      heapTotal: (memoryUsage.heapTotal / 1024 / 1024).toFixed(1),
    }

    // Disco
    const diskUsage = isWindows ? 'N/A (Windows)' : execSafe('df -h / | tail -1')

    // Docker
    const dockerContainers = isWindows
      ? execSafe('docker ps --format "{{.Names}} {{.Status}}"')
      : execSafe('docker ps --format "{{.Names}} {{.Status}}" 2>/dev/null || echo "docker nao disponivel"')

    // Database
    let dbStatus = 'desconhecido'
    try {
      const { prisma } = await import('@/lib/prisma')
      const count = await prisma.utilizador.count()
      dbStatus = `OK (${count} utilizadores)`
    } catch (e) {
      dbStatus = `ERRO: ${e}`
    }

    // Migrations
    let migrations = 'desconhecido'
    try {
      const { prisma } = await import('@/lib/prisma')
      const migs = await (prisma as unknown as { $queryRaw: (q: TemplateStringsArray) => Promise<Array<{ migration_name: string; finished_at: Date | null }>> })
        .$queryRaw`SELECT migration_name, finished_at FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 5`
      migrations = migs.map((m: { migration_name: string; finished_at: Date | null }) =>
        `${m.migration_name} (${m.finished_at ? 'OK' : 'PENDENTE'})`
      ).join('\n')
    } catch (e) {
      migrations = `ERRO: ${e}`
    }

    // Logs do update
    const updateLog = isWindows
      ? 'N/A (Windows)'
      : readFileSafe('/opt/backups/imoveo/update.log', 30)

    // Debug log
    const debugLog = isWindows
      ? 'N/A (Windows)'
      : readFileSafe('/opt/imoveo/debug.log', 30)

    // Update flag
    const updateFlagExists = !isWindows && existsSync('/opt/imoveo/UPDATE_REQUESTED')

    // Cron jobs
    const cronJobs = isWindows ? 'N/A (Windows)' : execSafe('crontab -l 2>/dev/null || echo "sem crontab"')

    // Ficheiros importantes
    const envProdExists = existsSync(join(appDir, '.env.prod'))
    const updateWatcherExists = existsSync(join(appDir, 'update-watcher.sh'))
    const maintenanceExists = existsSync(join(appDir, 'maintenance.html'))
    const backupShExists = existsSync(join(appDir, 'backup.sh'))

    // Nginx
    const nginxStatus = isWindows ? 'N/A (Windows)' : execSafe('nginx -t 2>&1 || echo "nginx nao instalado"')
    const nginxSitesEnabled = isWindows ? 'N/A' : execSafe('ls -la /etc/nginx/sites-enabled/ 2>/dev/null || echo "N/A"')

    // Timestamps
    const now = new Date().toISOString()
    const serverTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone

    return Response.json({
      data: {
        timestamp: now,
        timezone: serverTimezone,
        app: {
          version,
          gitCommit,
          gitBranch,
          gitLog,
          gitStatus: gitStatus || '(limpo)',
          uptime: uptimeFormatted,
        },
        sistema: {
          platform,
          nodeVersion,
          memoryMB,
          diskUsage,
        },
        docker: {
          containers: dockerContainers,
        },
        database: {
          status: dbStatus,
          recentMigrations: migrations,
        },
        update: {
          flagPending: updateFlagExists,
          log: updateLog,
        },
        debug: {
          log: debugLog,
        },
        nginx: {
          configTest: nginxStatus,
          sitesEnabled: nginxSitesEnabled,
        },
        cron: cronJobs,
        ficheiros: {
          envProd: envProdExists,
          updateWatcher: updateWatcherExists,
          maintenance: maintenanceExists,
          backupSh: backupShExists,
        },
      },
    })
  } catch (e) {
    console.error('[admin/debug] Error:', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao obter debug info', details: String(e) }, { status: 500 })
  }
}
