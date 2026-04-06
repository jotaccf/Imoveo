import { app } from 'electron'
import { join } from 'path'
import { mkdirSync } from 'fs'
import EmbeddedPostgres from 'embedded-postgres'

let pg: EmbeddedPostgres | null = null

export async function startPostgres(): Promise<string> {
  const dataDir = join(app.getPath('userData'), 'postgres', 'data')
  const socketDir = join(app.getPath('userData'), 'postgres', 'socket')
  mkdirSync(dataDir, { recursive: true })
  mkdirSync(socketDir, { recursive: true })

  pg = new EmbeddedPostgres({
    databaseDir: dataDir,
    user: 'imoveo',
    password: 'imoveo_local',
    port: 54320,
    persistent: true,
  })

  await pg.initialise()
  await pg.start()
  await pg.createDatabase('imoveo')

  const connStr = `postgresql://imoveo:imoveo_local@localhost:54320/imoveo`
  process.env.DATABASE_URL = connStr
  return connStr
}

export async function stopPostgres(): Promise<void> {
  if (pg) {
    await pg.stop()
    pg = null
  }
}
