#!/bin/bash
set -e

echo "=== Configuration de Docker Apps ==="

apt update && apt upgrade -y
hostnamectl set-hostname docker-apps

# SSH Hardening
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# UFW
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow from 10.0.0.2 to any port 22 proto tcp
ufw allow from 10.0.0.2 to any
ufw --force enable

# Docker
apt install docker.io docker-compose-v2 -y
systemctl enable docker

# Structure
mkdir -p /opt/docker/{immich,vaultwarden,portainer,uptime-kuma}

echo "=== Docker Apps prêt ==="
echo "1. Copier les docker-compose dans /opt/docker/"
echo "2. Copier .env.example vers .env et remplir les secrets"
echo "3. cd /opt/docker && docker compose up -d"
SCRIPT
chmod +x ~/infra-banou/scripts/setup-docker-apps.sh
