import { contextBridge, ipcRenderer } from 'electron'

contextBridge.exposeInMainWorld('electronAPI', {
  openInBrowser: () => ipcRenderer.invoke('open-in-browser'),
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  platform: process.platform,
})
