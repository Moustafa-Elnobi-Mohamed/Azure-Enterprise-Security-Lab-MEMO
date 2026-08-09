# MEMO Network Security Architecture

## Core Network

MEMO-VNET-CORE

CIDR:

10.10.0.0/16

Region:

East US

## Network Segmentation

### Application Tier

Subnet:

MEMO-SUBNET-APP

CIDR:

10.10.1.0/24

Security control:

MEMO-NSG-APP

Purpose:

Application workloads.

### Data Tier

Subnet:

MEMO-SUBNET-DATA

CIDR:

10.10.2.0/24

Security control:

MEMO-NSG-DATA

Purpose:

Database and data workloads.

### Management Tier

Subnet:

MEMO-SUBNET-MGMT

CIDR:

10.10.3.0/24

Security control:

MEMO-NSG-MGMT

Purpose:

Administrative management workloads.

### Security Tier

Subnet:

MEMO-SUBNET-SECURITY

CIDR:

10.10.4.0/24

Security control:

MEMO-NSG-SECURITY

Purpose:

Security tooling and controlled management access.

## Security Principles

- Network segmentation
- Least privilege
- Restricted management access
- Restricted database access
- Dedicated security subnet
- NSG enforcement at subnet boundaries
- Infrastructure as Code
- No unnecessary public exposure

## Cost Strategy

The network foundation intentionally avoids continuously billed infrastructure.

No Azure Firewall, NAT Gateway, VPN Gateway, Bastion, VM, or public IP infrastructure is required for this stage.

The objective is to demonstrate enterprise security architecture while maintaining a zero-cost lab posture.