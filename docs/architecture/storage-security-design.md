# MEMO Storage Security Design

## Architecture

MEMO uses a deployment-ready Azure Storage Terraform module configured with:

- Standard LRS
- StorageV2
- TLS 1.2 minimum
- HTTPS-only traffic
- Anonymous blob access disabled
- Shared Key authorization disabled
- Microsoft Entra ID authentication preferred
- Local users disabled
- Terraform lifecycle management

## Lab Deployment Decision

The Azure Storage resource is maintained as deployment-ready Infrastructure as Code.

The live resource is intentionally not deployed in the current lab because MEMO is operating under a zero-cost constraint.

Hands-on Storage workloads are tested locally using Azurite.

## Production Design

A production deployment would additionally evaluate:

- Private Endpoint
- Private DNS
- Storage firewall
- Managed Identity
- Azure RBAC
- Customer-managed encryption keys
- Defender for Storage
- Diagnostic settings
- Microsoft Sentinel integration