# Scenarios

## 1) Traffic Spike (10x)
Application Gateway distributes traffic across VMSS instances deployed across multiple AZs. VMSS can scale out with autoscale rules (recommended next step). For better performance: add autoscale, caching/CDN, and consider AKS for microservices.

## 2) Security Incident (Unauthorized Access Attempt)
Use Azure Monitor alerts/metrics, Log Analytics, and SQL auditing to investigate. Improve with WAF, tighter NSGs, JIT access, NSG flow logs, and anomaly alerts.

## 3) Cost Optimization (Reduce 30%)
Right-size VMSS and SQL tiers, lower baseline capacity in dev/staging, add autoscale to avoid overprovisioning, tune log retention, and use lifecycle policies to reduce storage costs.

## 4) Disaster Recovery (Region Down)
Deploy the same stack in a secondary region, use Azure SQL geo-replication, and front with Traffic Manager/Front Door for failover. RTO/RPO depend on replication/automation; warm standby improves RTO, continuous replication improves RPO.
