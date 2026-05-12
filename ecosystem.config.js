// ============================================================
//  IMOVEO — PM2 Ecosystem Configuration
//  Deploy bare metal (sem Docker)
// ============================================================

module.exports = {
  apps: [
    {
      name: 'imoveo',
      script: './server.js',
      cwd: '/opt/imoveo/current',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        HOSTNAME: '0.0.0.0',
      },
      // O .env é lido pelo Next.js automaticamente a partir de cwd
      // DATABASE_URL, NEXTAUTH_SECRET, etc. vêm de /opt/imoveo/current/.env (symlink)

      // Restart automático
      max_memory_restart: '500M',
      restart_delay: 3000,
      max_restarts: 10,

      // Logs
      error_file: '/opt/imoveo/logs/error.log',
      out_file: '/opt/imoveo/logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,

      // Graceful shutdown
      kill_timeout: 5000,
      listen_timeout: 10000,

      // Não watch em producao
      watch: false,
    },
  ],
}
