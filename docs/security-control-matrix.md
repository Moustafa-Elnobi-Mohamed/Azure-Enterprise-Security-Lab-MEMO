# MEMO Enterprise Security Control Matrix

## Purpose

This matrix maps the security controls implemented or validated in the MEMO Azure Enterprise Security Lab to their technical implementation, operational state, and supporting evidence.

## Control matrix

| Domain | Control | Implementation | State | Evidence | Result |
|---|---|---|---|---|---|
| Governance | Enterprise resource organization | Twelve MEMO resource groups separate identity, networking, security, monitoring, containers, departments, production, development, shared services, and sandbox resources | Live | `docs/evidence/day15/01-resource-groups.json` | PASS |
| Governance | Security posture management | Free Foundational CSPM and Discovery provide recommendations without enabling paid workload plans | Live | `docs/evidence/day15/03-defender-pricing.json` | PASS |
| Identity | Enterprise identity structure | Department-based Entra ID users, groups, role assignments, and RBAC documentation | Live and documented | `identity/`, `docs/RBAC/` | PASS |
| Workload identity | Secretless workload authentication | Azure managed identity and Key Vault Secrets User role replace application credentials | Live | Identity and Key Vault project evidence | PASS |
| Network security | Segmentation and traffic filtering | MEMO VNet, application, management, data, and security NSGs with controlled administration paths | Live | `infrastructure/networking/`, Terraform networking module | PASS |
| Secrets | Key Vault authorization | Azure RBAC authorization and least-privilege secret access | Live | `docs/evidence/day15/05-key-vault-validation.json` | PASS |
| Secrets | Deletion recovery | Soft delete and `MEMO-KV-Delete-Protection` CanNotDelete lock | Live | `docs/evidence/day15/06-resource-locks.json` | PASS |
| Secrets | Purge protection | Not enabled so the temporary lab can be fully removed; reversible deletion lock provides a compensating control | Lab exception | Python assurance report | DOCUMENTED EXCEPTION |
| Secrets | Network isolation | Public endpoint retained because private connectivity would add cost; RBAC and diagnostic monitoring provide compensating controls | Lab exception | Python assurance report | DOCUMENTED EXCEPTION |
| Monitoring | Centralized security telemetry | Log Analytics and Microsoft Sentinel collect Azure activity, diagnostic, alert, and incident data | Live | `docs/evidence/day15/09-log-analytics-usage.json` | PASS |
| Detection | Focused live analytics | Three representative rules cover RBAC changes, failed Azure operations, and failed Key Vault access | Live | `docs/evidence/day15/07-sentinel-rules.json` | PASS |
| Detection | Extended detection catalog | More than twenty additional detection artifacts remain in the repository for future telemetry sources | Repository | `detections/` | VALIDATED DESIGN |
| Incident response | Native incident triage | Sentinel automation adds a label and analyst investigation task without a Logic App | Live | `docs/evidence/day15/08-sentinel-automation.json` | PASS |
| Incident response | Evidence-based closure | Incident 22 was correlated with AzureActivity and closed as BenignPositive and SuspiciousButExpected | Live demonstration | `docs/evidence/day14/incident-22-investigation.md` | PASS |
| Containers | Cost-controlled Azure workload | Container Apps Consumption profile, minimum zero replicas, maximum one replica, 0.25 vCPU, and 0.5Gi memory | Live | `docs/evidence/day15/04-container-app-validation.json` | PASS |
| Containers | Managed workload identity | System-assigned identity is enabled and insecure HTTP ingress is disabled | Live | `docs/evidence/day15/04-container-app-validation.json` | PASS |
| Containers | Hardened Docker image | Non-root NGINX, UID/GID 101, port 8080, health check, security headers, and restricted build context | CI validated | `infrastructure/containers/memo-secure-app/` | PASS |
| Kubernetes | Restricted workload security | Non-root execution, read-only root filesystem, dropped capabilities, RuntimeDefault seccomp, limits, and disabled token mounting | Validated design | `infrastructure/kubernetes/` | PASS |
| Kubernetes | Network and identity isolation | Default-deny policies, controlled DNS egress, ClusterIP service, namespace RBAC, and dedicated service accounts | Validated design | `docs/evidence/day15/15-kubernetes-security-controls.txt` | PASS |
| Infrastructure as code | Terraform validation | Twenty-six Terraform files formatted, initialized without a backend, and validated without applying resources | Repository validated | `docs/evidence/day15/12-terraform-validation.txt` | PASS |
| Infrastructure as code | Bicep validation | Defender governance, policy governance, Sentinel detections, and Sentinel automation compile successfully | Live and repository validated | `docs/evidence/day15/13-bicep-validation.txt` | PASS |
| Automation | Python security assurance | Python evaluates live sanitized evidence using PASS, FAIL, and DOCUMENTED_EXCEPTION results | Automated | `automation/python/memo_security_validator.py` | PASS |
| DevSecOps | Continuous security validation | GitHub Actions validates Python, Terraform, Bicep, repository artifacts, and the hardened Docker runtime | Automated | `docs/evidence/day15/19-github-actions-validation.json` | PASS |
| AI security | Secure AI architecture | A design-only SOC assistant architecture applies managed identity, private connectivity, prompt protection, output validation, human approval, monitoring, and a kill switch | Validated design | `docs/architecture/ai-security/ai-security-architecture.md` | PASS |
| AI security | AI threat modeling | Twelve AI risks and twelve adversarial tests cover injection, disclosure, excessive agency, retrieval, output handling, supply chain, misinformation, identity, logging, and cost exhaustion | Validated design | `docs/architecture/ai-security/ai-threat-model.md` | PASS |
| AI security | Automated design assurance | Python validates required AI controls, risk identifiers, red-team tests, and the design-only deployment boundary | Automated | `automation/python/validate_ai_security_design.py` | PASS |
| Cost governance | Paid-service exclusion | Paid Defender workloads, AKS, ACR, private endpoints, and Logic App playbooks remain excluded | Live and documented | Day 15 cost evidence | PASS |
| Cost governance | Telemetry control | 3.881714 MB was ingested over 30 days and 0.063201 MB was marked billable | Live | `docs/evidence/day15/09a-log-analytics-totals.json` | PASS |

## Why only three Sentinel rules are live

The repository contains more than twenty detection artifacts, but only three representative analytics rules were deployed.

This was intentional. The three live rules demonstrate the complete lifecycle across identity, management-plane operations, and secrets:

1. Ingest relevant telemetry
2. Tune KQL against real records
3. Reduce duplicate results
4. Add entities and MITRE ATT&CK mappings
5. Group incidents
6. Automate triage
7. Investigate and classify an incident
8. Manage the rules through Bicep

Deploying every repository rule without its required telemetry would create inactive rules, unnecessary noise, confusing demonstrations, and possible ingestion costs.

## Validation boundary

The matrix distinguishes between:

- Live Azure controls
- CI-validated repository controls
- Validated designs not deployed to billable services
- Documented lab exceptions

No design-only artifact is represented as a live Azure deployment.
