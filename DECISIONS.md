# Decisions

## Why ARM Templates
ARM is Azure-native, supports full Azure resource coverage, and integrates cleanly with Azure CLI and GitHub Actions.

## Why VM Scale Set + Application Gateway
- VMSS maps well to “auto-scaling group” style requirements.
- Application Gateway provides L7 routing and health probes.
- This design keeps complexity lower than AKS while still demonstrating HA and scaling concepts.

## Why Azure SQL + Private Endpoint
- Managed database (patching/backups handled by Azure).
- Private Endpoint ensures database is not publicly accessible.
- Private DNS zone integration enables private name resolution.

## Secrets Management
Key Vault is used for centralized secret storage. VMSS has a managed identity and is granted least-privilege secret read access.

## Security
- Subnet segmentation (public vs private vs database)
- NSGs with least-privilege starter rules
- SQL public network access disabled
- TLS 1.2 enforced where applicable
