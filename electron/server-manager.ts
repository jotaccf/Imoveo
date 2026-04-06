import { app } from 'electron'
import { spawn, ChildProcess } from 'child_process'
import { join } from 'path'

let nextProcess: ChildProcess | null = null

export async function startNextServer(): Promise<void> {
  return new Promise((resolve, reject) => {
    const isDev = !app.isPackaged
    const serverPath = isDev
      ? join(__dirname, '../../node_modules/.bin/next')
      : join(process.resourcesPath, 'server', 'server.js')

    nextProcess = isDev
      ? spawn('node', [serverPath, 'dev'], {
          cwd: join(__dirname, '../..'),
          env: { ...process.env, PORT: '3000' },
        })
      : spawn('node', [serverPath], {
          env: { ...process.env, PORT: '3000', NODE_ENV: 'production' },
        })

    nextProcess.stdout?.on('data', (data: Buffer) => {
      const msg = data.toString()
      if (msg.includes('Ready') || msg.includes('started server')) {
        resolve()
      }
    })

    nextProcess.stderr?.on('data', (data: Buffer) => {
      console.error('[Next.js]', data.toString())
    })

    setTimeout(() => resolve(), 8000)
  })
}

export async function stopNextServer(): Promise<void> {
  if (nextProcess) {
    nextProcess.kill('SIGTERM')
    nextProcess = null
  }
}
