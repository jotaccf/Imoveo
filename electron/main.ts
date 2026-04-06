import { app, BrowserWindow, shell } from 'electron'
import { join } from 'path'
import { startPostgres, stopPostgres } from './pg-manager'
import { startNextServer, stopNextServer } from './server-manager'
import { setupTray } from './tray-manager'
import { execSync } from 'child_process'

let mainWindow: BrowserWindow | null = null
const APP_URL = 'http://localhost:3000'

async function runMigrations(): Promise<void> {
  const prismaPath = app.isPackaged
    ? join(process.resourcesPath, 'node_modules', '.bin', 'prisma')
    : join(__dirname, '../../node_modules/.bin/prisma')
  try {
    execSync(`${prismaPath} migrate deploy`, {
      env: process.env,
      cwd: app.isPackaged ? process.resourcesPath : join(__dirname, '../..'),
    })
    execSync(`${prismaPath} db seed`, {
      env: { ...process.env, SEED_IF_EMPTY: 'true' },
      cwd: app.isPackaged ? process.resourcesPath : join(__dirname, '../..'),
    })
  } catch (e) {
    console.error('Migration error:', e)
  }
}

async function createWindow(): Promise<void> {
  mainWindow = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 960,
    minHeight: 600,
    title: 'Imoveo',
    icon: join(__dirname, '../resources/icon.png'),
    webPreferences: {
      preload: join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
    },
    backgroundColor: '#F4FAF8',
    show: false,
  })

  mainWindow.once('ready-to-show', () => mainWindow?.show())

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url)
    return { action: 'deny' }
  })

  await mainWindow.loadURL(APP_URL)
}

app.whenReady().then(async () => {
  const splash = new BrowserWindow({
    width: 400, height: 300,
    frame: false, alwaysOnTop: true,
    backgroundColor: '#0D1B1A',
    transparent: false,
  })
  splash.loadFile(join(__dirname, '../resources/splash.html'))

  try {
    await startPostgres()
    await runMigrations()
    await startNextServer()
    await createWindow()
    setupTray(mainWindow!, APP_URL)
  } finally {
    splash.close()
  }
})

app.on('before-quit', async () => {
  await stopNextServer()
  await stopPostgres()
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow()
})
