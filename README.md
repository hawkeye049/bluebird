# Bluebird Cloud Engineer Exercise (Azure + ARM)

This repository deploys a resilient multi-tier web application foundation on Azure using ARM templates.

What you MUST update before deploying

In main.json, update the fileUris line under VMSS CustomScript extension to point to your real bootstrap.sh URL, for example:

GitHub raw URL once the repo exists:
https://raw.githubusercontent.com/<you>/bluebird-cloud-exercise/main/scripts/bootstrap.sh

Ensure you can deploy App Gateway in your chosen region (quota/feature availability). If you hit limits, tell me your region and I’ll adjust SKUs.

## Architecture (High Level)
- Application Gateway (public entry) in a public subnet
- VM Scale Set (web/app tier) in a private subnet behind the gateway
- Azure SQL Database with Private Endpoint (not publicly accessible)
- NAT Gateway for outbound access from private subnet
- Storage Account for static assets
- Key Vault for secret storage (VMSS identity has secret read access)

## Prerequisites
- Azure subscription (free/trial OK)
- Azure CLI installed and logged in (`az login`)
- PowerShell (for deploy script)

## Deploy (Local)
1. Clone repo
2. From repo root:
   ```powershell
   ./scripts/deploy.ps1 -SubscriptionId "<SUB_ID>" -ResourceGroupName "bbg-rg-dev" -Location "eastus2" -Environment "dev"
