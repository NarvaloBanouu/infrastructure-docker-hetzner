#!/bin/bash
set -e

echo "=== Configuration du Bastion ==="

apt update && apt upgrade -y
hostnamectl set-hostname bastion

# SSH Hardening
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Fail2ban
apt install fail2ban -y
cp /root/infra-banou/fail2ban/jail.local /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl restart fail2ban

# UFW
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Nginx + Certbot
apt install nginx certbot python3-certbot-nginx -y
systemctl enable nginx

# Copier et activer les configs Nginx
cp /root/infra-banou/nginx/*.banou.ovh /etc/nginx/sites-available/
for site in /etc/nginx/sites-available/*.banou.ovh; do
    ln -sf "$site" /etc/nginx/sites-enabled/
done
nginx -t && systemctl reload nginx

echo "=== Bastion prêt ==="
echo "Lancer : certbot --nginx -d immich.banou.ovh -d vault.banou.ovh -d portainer.banou.ovh -d uptime.banou.ovh"
SCRIPT
chmod +x ~/infra-banou/scripts/setup-bastion.sh
