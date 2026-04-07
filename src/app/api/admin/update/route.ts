import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { writeFileSync, existsSync } from 'fs'
import { spawn } from 'child_process'
import { debugLog, debugError } from '@/lib/debug-logger'

const isWindows = process.platform === 'win32'

// Detectar ambiente: Docker (flag) vs Bare Metal (CLI directo)
const isDocker = existsSync('/.dockerenv') || existsSync('/app/shared')
const FLAG_PATH = isDocker ? '/app/shared/UPDATE_REQUESTED' : ''
const IMOVEO_CLI = '/usr/local/bin/imoveo'

export async function POST() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    const user = (session.user as { nome?: string })?.nome || 'desconhecido'
    debugLog('update', `Update solicitado por ${user}`)

    if (isWindows) {
      return Response.json({ message: 'Update nao disponivel em Windows' }, { status: 400 })
    }

    if (isDocker) {
      // Docker: escrever flag para o watcher no host
      writeFileSync(FLAG_PATH, new Date().toISOString())
      debugLog('update', `Flag Docker criada em ${FLAG_PATH}`)

      return Response.json({
        message: 'Actualizacao agendada. A aplicacao ira reiniciar em breve.',
        mode: 'docker',
      }, { status: 202 })
    }

    // Bare metal: executar imoveo update em background
    if (!existsSync(IMOVEO_CLI)) {
      debugLog('update', 'AVISO: CLI imoveo nao encontrado')
      return Response.json({ error: 'CLI imoveo nao encontrado em ' + IMOVEO_CLI }, { status: 500 })
    }

    debugLog('update', 'A executar imoveo update (bare metal)...')

    const child = spawn('sudo', [IMOVEO_CLI, 'update'], {
      detached: true,
      stdio: 'ignore',
      cwd: '/opt/imoveo',
    })
    child.unref()

    return Response.json({
      message: 'Actualizacao iniciada. A pagina entrara em modo de manutencao.',
      mode: 'baremetal',
    }, { status: 202 })
  } catch (e) {
    debugError('update', e)
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao iniciar actualizacao', details: String(e) }, { status: 500 })
  }
}
