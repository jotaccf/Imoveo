import { Tray, Menu, BrowserWindow, nativeImage, shell, app } from 'electron'
import { join } from 'path'

let tray: Tray | null = null

export function setupTray(mainWindow: BrowserWindow, appUrl: string): void {
  const icon = nativeImage.createFromPath(join(__dirname, '../resources/icon.png'))
    .resize({ width: 16, height: 16 })

  tray = new Tray(icon)
  tray.setToolTip('Imoveo — Gestao Patrimonial')

  const menu = Menu.buildFromTemplate([
    {
      label: 'Abrir Imoveo',
      click: () => { mainWindow.show(); mainWindow.focus() },
    },
    {
      label: 'Abrir no browser',
      click: () => shell.openExternal(appUrl),
    },
    { type: 'separator' },
    { label: 'Estado: Em execucao', enabled: false },
    { type: 'separator' },
    { label: 'Sair', click: () => app.quit() },
  ])

  tray.setContextMenu(menu)
  tray.on('double-click', () => { mainWindow.show(); mainWindow.focus() })
}
