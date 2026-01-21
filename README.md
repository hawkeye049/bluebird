# Bluebird Cloud Engineer Exercise — Azure High Availability (ARM)

This repository deploys a resilient, secure Azure architecture using ARM templates.

## Bootstrap Script Source (your branch)
The VM Scale Set bootstraps using this script:
https://raw.githubusercontent.com/hawkeye049/bluebird/refs/heads/bluebird-cloud-exercise/scripts/bootstrap.sh

## How this meets the Technical Requirements

### 1) Network Layer
- VNet with public + private subnets (public, app, db)
- Subnets are deployed in an Availability Zone-enabled region, and compute/ingress are zonal
- NAT Gateway provides outbound internet access for the private app subnet
- Least-privilege NSGs:
  - Public subnet allows only HTTP (80) inbound to Application Gateway
  - App subnet denies internet inbound; allows only from public subnet on 80
  - DB subnet allows only 1433 inbound from app subnet; SQL public access disabled

### 2) Compute Layer
- VM Scale Set (2–4 instances) across at least 2 Availability Zones (`zones` + `zoneBalance`)
- Application Gateway v2 is zone-redundant and load balances traffic to VMSS
- Bootstrap via Custom Script Extension pulling `bootstrap.sh`
- Health probe configured at `/health`

### 3) Database Layer
- Azure SQL Database (managed)
- Zone redundancy enabled for staging/prod (`zoneRedundant: true`) where supported
- Automated backups are enabled by default for Azure SQL Database
- Database is not public: SQL public network access disabled + Private Endpoint + Private DNS

### 4) Storage
- Storage Account (Blob) for static assets
- HTTPS-only, TLS 1.2, no public blob access
- Lifecycle policy deletes blobs under `static/` after 90 days

### 5) Security
- Key Vault stores DB credentials (secret: `sql-admin-password`)
- VMSS uses Managed Identity and has least-privilege Key Vault permissions (get/list secrets)
- Encryption at rest is enabled by default for Azure SQL and Storage; TLS 1.2 enforced for storage

### 6) Monitoring & Logging (Bonus)
- Log Analytics Workspace + Application Insights
- CPU metric alert triggers if average VMSS CPU > 80% over 10 minutes

## Deploy Locally
Prereqs:
- Azure CLI installed
- PowerShell
- `az login` completed

```powershell
./scripts/deploy.ps1 -SubscriptionId "<SUB_ID>" -ResourceGroupName "bbg-rg-dev" -Location "eastus2" -Environment "dev"
