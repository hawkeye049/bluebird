# Improvements (If More Time)

- Enforce HTTPS end-to-end (TLS on App Gateway + backend TLS) and store cert in Key Vault
- Enable WAF policy on Application Gateway
- Add autoscale rules for VMSS (CPU/custom metrics) beyond static capacity
- Add diagnostic settings for App Gateway/SQL/VMSS into Log Analytics (centralized logging)
- Add NSG flow logs + Traffic Analytics
- Add blue/green or canary deployments
- Containerize the app and deploy to AKS for more realistic microservices
- Add private endpoints for Storage and a CDN for static assets
