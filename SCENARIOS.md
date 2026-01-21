# Scenarios

## 1. Traffic Spike (10x)
The Application Gateway distributes load across VMSS instances, and VMSS can scale out (with autoscale rules added). For better performance, add autoscale policies, caching/CDN for static assets, and consider AKS with HPA for microservices.

## 2. Security Incident (Unauthorized Access Attempt)
Use Azure Monitor logs, NSG flow logs, Application Gateway access logs, and SQL auditing to trace activity. Improve security with WAF, tighter NSG rules, Just-In-Time access, and alerting on anomalous patterns.

## 3. Cost Optimization (Reduce 30%)
Right-size VM SKUs, reduce baseline VMSS instance count, use reserved instances/savings plans where appropriate, move SQL to lower tier if possible, and add autoscale to avoid overprovisioning. Use Storage lifecycle policies and log retention tuning.

## 4. Disaster Recovery (Region Down)
Use multi-region strategy: secondary region deployment with replicated data (SQL geo-replication) and DNS/Traffic Manager/Front Door failover. RTO/RPO depend on replication and automation; target lower RPO with continuous replication and lower RTO with warm standby.
