# Infrastructure Self-Hosted - banou.ovh

## Architecture
```
Internet (HTTPS) → Bastion (Nginx + SSL) → Private Network (10.0.0.0/24) → Docker Apps
```

| Serveur | Type | IP Publique | IP Privée |
|---------|------|-------------|-----------|
| Bastion | CX23 (2c/4GB) | <IP_DU_BASTION> | 10.0.0.2 |
| Docker-apps | CX53 (16c/32GB) | <IP_DOCKER> | 10.0.0.3 |

## Services

| Service | URL | Port interne |
|---------|-----|-------------|
| Immich (photos) | https://immich.banou.ovh | 10.0.0.3:2283 |
| Vaultwarden (mots de passe) | https://vault.banou.ovh | 10.0.0.3:8080 |
| Portainer (gestion Docker) | https://portainer.banou.ovh | 10.0.0.3:9000 |
| Uptime Kuma (monitoring) | https://uptime.banou.ovh | 10.0.0.3:3001 |

## Déploiement

### Prérequis
- 2 VPS Hetzner Cloud avec Private Network (10.0.0.0/24)
- Domaine avec enregistrements A pointant vers l'IP du Bastion
- Clé SSH

### 1. DNS
Ajouter enregistrements A vers l'IP du Bastion pour :
banou.ovh, immich.banou.ovh, vault.banou.ovh, portainer.banou.ovh, uptime.banou.ovh

### 2. Bastion
```bash
scp scripts/setup-bastion.sh root@<IP_BASTION>:/root/
ssh root@<IP_BASTION> bash /root/setup-bastion.sh
scp nginx/*.banou.ovh root@<IP_BASTION>:/etc/nginx/sites-available/
ssh root@<IP_BASTION> "ln -s /etc/nginx/sites-available/*.banou.ovh /etc/nginx/sites-enabled/ && nginx -t && systemctl reload nginx"
ssh root@<IP_BASTION> "certbot --nginx -d immich.banou.ovh -d vault.banou.ovh -d portainer.banou.ovh -d uptime.banou.ovh"
```

### 3. Docker Apps
```bash
scp scripts/setup-docker-apps.sh root@<IP_DOCKER>:/root/
ssh root@<IP_DOCKER> bash /root/setup-docker-apps.sh
scp -r docker/* root@<IP_DOCKER>:/opt/docker/
ssh root@<IP_DOCKER> "cp /opt/docker/immich/.env.example /opt/docker/immich/.env && nano /opt/docker/immich/.env"
ssh root@<IP_DOCKER> "cd /opt/docker && docker compose up -d"
```

### SSH Config (Mac/Linux)
```
Host bastion
    HostName <IP_BASTION>
    User root
    IdentityFile ~/.ssh/hetzner_openstack

Host docker-apps
    HostName 10.0.0.3
    User root
    ProxyJump bastion
    IdentityFile ~/.ssh/hetzner_openstack
```
