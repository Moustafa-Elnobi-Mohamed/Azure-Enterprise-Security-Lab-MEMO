# MEMO Network Foundation

The MEMO Foundation lab uses a segmented Azure virtual network designed to demonstrate enterprise network security architecture.

## Architecture

VNet:

`MEMO-VNET-CORE`

Address space:

`10.10.0.0/16`

### Subnets

| Subnet               | CIDR         | Purpose                  | NSG               |
| -------------------- | ------------ | ------------------------ | ----------------- |
| MEMO-SUBNET-APP      | 10.10.1.0/24 | Application workloads    | MEMO-NSG-APP      |
| MEMO-SUBNET-DATA     | 10.10.2.0/24 | Data workloads           | MEMO-NSG-DATA     |
| MEMO-SUBNET-MGMT     | 10.10.3.0/24 | Administrative workloads | MEMO-NSG-MGMT     |
| MEMO-SUBNET-SECURITY | 10.10.4.0/24 | Security tooling         | MEMO-NSG-SECURITY |

## Security Controls

The network layer currently demonstrates:

- Network segmentation
- Application tier isolation
- Data tier protection
- Management tier isolation
- Security tooling isolation
- Network Security Groups
- Explicit inbound deny rules
- Controlled HTTPS/HTTP access for the application tier
- Infrastructure-as-code style PowerShell automation

## Cost Considerations

This portion of the lab intentionally avoids paid networking services.

The lab does not currently deploy:

- Azure Firewall
- NAT Gateway
- VPN Gateway
- Azure Bastion
- Public IP addresses
- Virtual machines

The goal is to demonstrate the architecture and security controls while keeping the lab cost at $0.

## Automation

The network foundation can be recreated using:

```text
scripts/01-create-vnet.ps1
scripts/02-create-nsgs.ps1
scripts/03-configure-network-security.ps1