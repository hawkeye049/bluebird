#!/usr/bin/env bash
set -euo pipefail

SQL_SERVER_NAME="${1:-}"
SQL_DB_NAME="${2:-}"
KEYVAULT_NAME="${3:-}"
SECRET_NAME="${4:-}"

sudo apt-get update -y
sudo apt-get install -y nginx curl ca-certificates gnupg lsb-release

# Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Azure CLI (for Key Vault secret retrieval via Managed Identity)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Attempt to retrieve DB password from Key Vault using VMSS Managed Identity
DB_PASSWORD=""
if [[ -n "$KEYVAULT_NAME" && -n "$SECRET_NAME" ]]; then
  set +e
  DB_PASSWORD="$(az keyvault secret show --vault-name "$KEYVAULT_NAME" --name "$SECRET_NAME" --query value -o tsv 2>/dev/null)"
  set -e
fi

sudo mkdir -p /opt/bbg-app

cat <<'EOF' | sudo tee /opt/bbg-app/app.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Bluebird Group - Cloud Engineer Assessment',
    instance: process.env.HOSTNAME || 'unknown',
    timestamp: new Date().toISOString(),
    dbConfigured: !!process.env.SQL_SERVER
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => console.log(`App running on port ${port}`));
EOF

cd /opt/bbg-app
sudo npm init -y >/dev/null 2>&1
sudo npm install express >/dev/null 2>&1

cat <<EOF | sudo tee /etc/systemd/system/bbg-app.service
[Unit]
Description=BBG Sample Node App
After=network.target

[Service]
WorkingDirectory=/opt/bbg-app
ExecStart=/usr/bin/node /opt/bbg-app/app.js
Restart=always
Environment=PORT=3000
Environment=SQL_SERVER=${SQL_SERVER_NAME}
Environment=SQL_DATABASE=${SQL_DB_NAME}
Environment=SQL_PASSWORD=${DB_PASSWORD}

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now bbg-app

# Nginx reverse proxy on port 80
cat <<'EOF' | sudo tee /etc/nginx/sites-available/default
server {
  listen 80 default_server;
  listen [::]:80 default_server;

  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
EOF

sudo nginx -t
sudo systemctl restart nginx

echo "Bootstrap complete."
