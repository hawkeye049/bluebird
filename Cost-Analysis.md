This document estimates **monthly costs for a multi-region deployment** of the Bluebird Cloud HA architecture using:
- **Primary Region:** East US 2 (East Coast)
- **Secondary Region:** West US 2 (West Coast)

Architecture is deployed **in both regions** for high availability and disaster recovery readiness.

---

## Architecture Summary (Per Region)
- Application Gateway v2 (zone-redundant)
- VM Scale Set (Standard_B2s, zonal, zone-balanced)
- NAT Gateway for private subnet egress
- Azure SQL Database (managed, private endpoint)
- Storage Account (Blob) with lifecycle policy
- Key Vault (secrets)
- Log Analytics + Application Insights
- Public IPs (App Gateway + NAT)

---

## Assumptions
- Region pricing parity between East US 2 and West US 2
- 730 hours/month
- Light to moderate traffic
- App Gateway avg ~1 capacity unit
- VMSS:
  - Dev/Staging: 2 instances
  - Prod: 3 instances
- Logging: ~1 GB/day per environment
- Storage: ~20 GB hot tier
- SQL:
  - Dev: Basic
  - Staging/Prod: S0
- Outbound data and DR replication traffic not included (variable)

---

## Per-Region Monthly Cost Estimate

| Environment | Estimated Monthly Cost (per region) |
|---|---:|
| Dev | ~$386 |
| Staging | ~$390 |
| Prod | ~$427 |

**Total per region:** **~$1,203 / month**

---

## Multi-Region Total Cost (East + West)

| Deployment Model | Monthly Cost |
|---|---:|
| Single Region (baseline) | ~$1,200 |
| Dual Region (East + West) | **~$2,400** |

> This reflects **full active-active infrastructure** in both regions.

---

## Cost Drivers (Per Region)
- Application Gateway v2: ~$186/month
- VMSS Compute:
  - 2× B2s ≈ ~$72/month
  - 3× B2s ≈ ~$109/month
- NAT Gateway: ~$33/month + data processed
- Azure SQL:
  - Basic: ~$10/month
  - S0: ~$15/month
- Log Analytics/App Insights: ~$69/month (assumed volume)

---

## Disaster Recovery Models & Cost Impact

### Option 1: Active-Active (Current Estimate)
- Full stack in both regions
- Traffic routed via Azure Front Door or Traffic Manager
- **Highest availability**
- **Highest cost (~$2,400/month)**

### Option 2: Active-Passive (Warm Standby)
- Secondary region:
  - VMSS scaled to 0–1 instances
  - Lower SQL tier or paused where possible
- Estimated savings: **30–40%**
- Approximate cost: **~$1,600–$1,800/month**

### Option 3: Cold Standby
- Infrastructure deployed but compute disabled
- Manual or automated failover
- Lowest cost
- Approximate cost: **~$1,300–$1,400/month**

---

## What Can Increase Costs Quickly
- Application Gateway capacity units during traffic spikes
- NAT Gateway data processing (per-GB billing)
- High log ingestion volume
- SQL zone redundancy or higher DTU/vCore tiers
- Cross-region replication and data egress

---

## Cost Optimization Recommendations
- Use **Active-Passive** for non-production environments
- Reduce baseline VMSS instance count in secondary region
- Tune log retention and verbosity
- Consider Front Door Standard instead of multiple App Gateways if allowed
- Use Azure SQL geo-replication selectively

---

## Summary
- **Single region HA:** ~$1,200/month
- **Dual region (East + West) active-active:** ~$2,400/month
- **Dual region with DR optimization:** ~$1,600–$1,800/month

This model satisfies enterprise-grade **high availability, disaster recovery, and regional resilience** expectations while clearly showing cost trade-offs.

