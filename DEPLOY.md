# Imoveo — Guia de Instalacao em Producao
## Ubuntu 22.04 LTS em Hyper-V

---

## 1. Preparar a VM Ubuntu no Hyper-V

No Windows (host), abrir Hyper-V Manager:
- Nova Maquina Virtual > Geracao 2
- RAM: 4 GB (minimo) / 8 GB (recomendado)
- CPU: 2 vCPUs
- Disco: 60 GB
- ISO: Ubuntu Server 22.04 LTS
- Instalar Ubuntu com configuracao padrao

---

## 2. Configurar IP fixo na VM

SSH para a VM apos instalacao e configurar IP fixo:

    sudo nano /etc/netplan/00-installer-config.yaml

Conteudo (ajustar ao teu range de rede):

    network:
      version: 2
      ethernets:
        eth0:
          addresses: [192.168.1.50/24]
          gateway4: 192.168.1.1
          nameservers:
            addresses: [8.8.8.8, 1.1.1.1]

Aplicar:

    sudo netplan apply
    ip addr show eth0  # confirmar IP

---

## 3. Instalar Docker na VM

    sudo apt update && sudo apt upgrade -y
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    newgrp docker
    sudo apt install -y docker-compose-plugin
    docker --version
    docker compose version

---

## 4. Exportar para GitHub (fazer em Windows antes do deploy)

No VS Code terminal (Windows):

    cd imoveo
    git add .
    git commit -m "feat: versao inicial Imoveo"
    git remote add origin https://github.com/SEU_UTILIZADOR/imoveo.git
    git branch -M main
    git push -u origin main

---

## 5. Clonar e configurar na VM Ubuntu

    git clone https://github.com/SEU_UTILIZADOR/imoveo.git /opt/imoveo
    cd /opt/imoveo

Criar ficheiro de variaveis de ambiente:

    cp .env.example .env.prod
    nano .env.prod

Preencher:

    POSTGRES_PASSWORD=escolher-uma-password-forte-aqui
    NEXTAUTH_SECRET=$(openssl rand -base64 32)
    NEXTAUTH_URL=http://192.168.1.50
    NODE_ENV=production

---

## 6. Arrancar a aplicacao

    cd /opt/imoveo

    # Build e arranque de todos os servicos
    docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

    # Aguardar arranque (30-60 segundos)
    docker compose -f docker-compose.prod.yml ps

    # Executar migrations na base de dados (primeira vez)
    docker compose -f docker-compose.prod.yml exec app npx prisma migrate deploy

    # Inserir dados iniciais (rubricas, utilizadores de teste)
    docker compose -f docker-compose.prod.yml exec app npx prisma db seed

    # Verificar logs
    docker compose -f docker-compose.prod.yml logs -f app

---

## 7. Aceder a aplicacao

Abrir browser em qualquer PC da rede local:

    http://192.168.1.50

Credenciais iniciais:

    Admin:    admin@imoveo.local    / Imoveo2024!
    Gestor:   gestor@imoveo.local   / Imoveo2024!
    Operador: operador@imoveo.local / Imoveo2024!

IMPORTANTE: Alterar as passwords imediatamente apos o primeiro login.
Ir a Utilizadores > Editar para cada conta.

---

## 8. Configurar backup automatico

    cat > /opt/imoveo/backup.sh << 'SCRIPT'
    #!/bin/bash
    DATE=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR=/opt/backups/imoveo
    mkdir -p $BACKUP_DIR
    docker compose -f /opt/imoveo/docker-compose.prod.yml exec -T postgres \
      pg_dump -U imoveo imoveo > $BACKUP_DIR/imoveo_$DATE.sql
    ls -t $BACKUP_DIR/*.sql | tail -n +31 | xargs -r rm
    echo "$(date): Backup concluido: imoveo_$DATE.sql"
    SCRIPT

    chmod +x /opt/imoveo/backup.sh

    # Agendar: backup diario as 02:00
    (crontab -l 2>/dev/null; echo "0 2 * * * /opt/imoveo/backup.sh >> /var/log/imoveo-backup.log 2>&1") | crontab -

Os backups ficam em /opt/backups/imoveo/
Sao mantidos os ultimos 30 ficheiros.
Podem ser copiados para o Windows via pasta partilhada Hyper-V ou SFTP.

---

## 9. Actualizacoes futuras

Quando houver nova versao no GitHub:

    cd /opt/imoveo
    git pull origin main
    docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --build
    docker compose -f docker-compose.prod.yml exec app npx prisma migrate deploy

---

## 10. Comandos uteis de manutencao

    # Ver estado dos servicos
    docker compose -f docker-compose.prod.yml ps

    # Ver logs em tempo real
    docker compose -f docker-compose.prod.yml logs -f app
    docker compose -f docker-compose.prod.yml logs -f postgres

    # Reiniciar servico especifico
    docker compose -f docker-compose.prod.yml restart app

    # Parar tudo
    docker compose -f docker-compose.prod.yml down

    # Restaurar backup
    docker compose -f docker-compose.prod.yml exec -T postgres \
      psql -U imoveo imoveo < /opt/backups/imoveo/imoveo_YYYYMMDD_HHMMSS.sql

    # Aceder ao Prisma Studio (interface visual da BD)
    docker compose -f docker-compose.prod.yml exec app npx prisma studio
    # Aceder em http://192.168.1.50:5555
