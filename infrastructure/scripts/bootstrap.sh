#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y nginx curl ca-certificates

# Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Create app
sudo mkdir -p /opt/bbg-app
cat <<'EOF' | sudo tee /opt/bbg-app/app.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Bluebird Group - Cloud Engineer Assessment',
    instance: process.env.HOSTNAME || 'unknown',
    timestamp: new Date().toISOString()
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

# systemd service
cat <<'EOF' | sudo tee /etc/systemd/system/bbg-app.service
[Unit]
Description=BBG Sample Node App
After=network.target

[Service]
WorkingDirectory=/opt/bbg-app
ExecStart=/usr/bin/node /opt/bbg-app/app.js
Restart=always
Environment=PORT=3000

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
