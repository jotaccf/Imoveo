import { auth } from '@/lib/auth'
import { requirePermission, type Role } from '@/lib/permissions'
import { execSync } from 'child_process'

const isWindows = process.platform === 'win32'

function execSafe(cmd: string, timeout = 10000): { ok: boolean; output: string } {
  try {
    const output = execSync(cmd, { timeout, encoding: 'utf-8' }).trim()
    return { ok: true, output }
  } catch (e) {
    return { ok: false, output: e instanceof Error ? e.message : String(e) }
  }
}

// GET — estado do Tailscale
export async function GET() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    if (isWindows) {
      return Response.json({ data: { installed: false, status: 'N/A (Windows)' } })
    }

    // Verificar se tailscale esta instalado
    const installed = execSafe('which tailscale')
    if (!installed.ok) {
      return Response.json({ data: { installed: false, status: 'Nao instalado' } })
    }

    // Obter estado
    const status = execSafe('sudo tailscale status --json')
    if (!status.ok) {
      return Response.json({ data: { installed: true, connected: false, status: 'Desconectado' } })
    }

    try {
      const json = JSON.parse(status.output)
      const self = json.Self || {}
      return Response.json({
        data: {
          installed: true,
          connected: json.BackendState === 'Running',
          status: json.BackendState === 'Running' ? 'Conectado' : 'Desconectado',
          ip: self.TailscaleIPs?.[0] || null,
          hostname: self.HostName || null,
          os: self.OS || null,
          version: json.Version || null,
        },
      })
    } catch {
      return Response.json({ data: { installed: true, connected: false, status: 'Erro ao ler estado' } })
    }
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}

// POST — autenticar com auth key
export async function POST(req: Request) {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    if (isWindows) {
      return Response.json({ error: 'Tailscale nao disponivel em Windows' }, { status: 400 })
    }

    const body = await req.json()
    const { authKey } = body

    if (!authKey || !authKey.startsWith('tskey-')) {
      return Response.json({ error: 'Auth key invalida. Deve comecar com tskey-' }, { status: 400 })
    }

    // Executar tailscale up com auth key
    const result = execSafe(`sudo tailscale up --authkey=${authKey} --accept-routes`, 30000)

    if (!result.ok) {
      return Response.json({
        error: 'Erro ao autenticar Tailscale',
        details: result.output,
      }, { status: 500 })
    }

    // Verificar estado apos autenticacao
    const status = execSafe('sudo tailscale status --json')
    let ip = ''
    if (status.ok) {
      try {
        const json = JSON.parse(status.output)
        ip = json.Self?.TailscaleIPs?.[0] || ''
      } catch { /* */ }
    }

    return Response.json({
      message: 'Tailscale autenticado com sucesso',
      ip,
    })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro ao configurar Tailscale', details: String(e) }, { status: 500 })
  }
}

// DELETE — desconectar
export async function DELETE() {
  try {
    const session = await auth()
    if (!session) return Response.json({ error: 'Nao autenticado' }, { status: 401 })
    requirePermission(session.user.role as Role, 'utilizadores:editar')

    if (isWindows) {
      return Response.json({ error: 'Tailscale nao disponivel em Windows' }, { status: 400 })
    }

    execSafe('sudo tailscale logout', 15000)
    return Response.json({ message: 'Tailscale desconectado' })
  } catch (e) {
    if ((e as Error).message?.startsWith('Acesso negado')) return Response.json({ error: (e as Error).message }, { status: 403 })
    return Response.json({ error: 'Erro interno' }, { status: 500 })
  }
}
