import { appendFileSync, mkdirSync } from 'fs'
import { join, dirname } from 'path'

const isWindows = process.platform === 'win32'
const LOG_PATH = isWindows
  ? join(process.cwd(), 'debug.log')
  : '/opt/imoveo/debug.log'

// Garantir que o directorio existe
try { mkdirSync(dirname(LOG_PATH), { recursive: true }) } catch { /* ignore */ }

export function debugLog(source: string, message: string, data?: unknown) {
  const timestamp = new Date().toISOString()
  let line = `[${timestamp}] [${source}] ${message}`
  if (data !== undefined) {
    line += ` | ${typeof data === 'string' ? data : JSON.stringify(data)}`
  }
  line += '\n'

  try {
    appendFileSync(LOG_PATH, line)
  } catch {
    // Fallback para console se nao conseguir escrever
    console.error(line)
  }
}

export function debugError(source: string, error: unknown) {
  const msg = error instanceof Error
    ? `${error.message}\n${error.stack}`
    : String(error)
  debugLog(source, `ERRO: ${msg}`)
}
