# MEMO Database Security Architecture

## Proposed Database Layer

Application
    |
    v
Managed Identity
    |
    v
Microsoft Entra ID
    |
    v
Database
    |
    +-- Encryption at Rest
    +-- Auditing
    +-- Threat Detection
    +-- Least Privilege
    +-- Backup
    +-- Monitoring

## Security Controls

- Microsoft Entra authentication
- Least privilege database roles
- Encryption at rest
- Encryption in transit
- Auditing
- Defender for SQL where applicable
- Network isolation
- Private access for production
- No plaintext credentials in applications

## MEMO Data Zones

Production
Sensitive business data

Development
Synthetic/non-production data

Security
Security telemetry

Sandbox
Testing data only

## Important

Production data must never be copied into development or sandbox
environments without appropriate controls and authorization.