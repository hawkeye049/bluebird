# Decisions

## HA Strategy (Multi-AZ)
- Application Gateway v2 is deployed across Availability Zones (zones parameter).
- VM Scale Set instances are deployed across the same zones with zone balancing enabled.
- Azure SQL Database uses zone redundancy for staging/prod where supported.

## Tier Model
- Web/Ingress tier: Application Gateway (public subnet)
- App tier: VMSS (private subnet)
- Data tier: Azure SQL (private endpoint in db subnet)

## Why ARM Templates
Azure-native IaC with broad service coverage and strong integration with Azure CLI and CI/CD.

## Security Choices
- Subnet segmentation + least-privilege NSGs
- SQL public network access disabled + Private Endpoint + Private DNS
- Key Vault for secret storage; VMSS Managed Identity has secret get/list only

## Cost Control
- Dev uses SQL Basic
- Staging/Prod use S0 (adjustable based on budget/performance)
- Storage lifecycle policy reduces long-term blob costs
