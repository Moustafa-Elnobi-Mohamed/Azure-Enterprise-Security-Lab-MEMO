# MEMO Secure Compute Architecture

## Objective

## Secure VM Baseline

## Network Exposure

The MEMO management NSG was reviewed to verify administrative port exposure.

RDP on TCP 3389 and SSH on TCP 22 are restricted to the dedicated management subnet `10.10.3.0/24`.

Neither rule is configured with an Internet-wide source such as `0.0.0.0/0`.

This provides network-level segmentation for administrative access.

In a production environment, Just-in-Time access could further reduce exposure by opening management ports only when specifically requested for a limited period.

## Authentication

## Trusted Launch

## Managed Identity

## Disk Protection

## Just-in-Time Access

## Defender for Servers

## Cost-Control Decision

The secure VM architecture was implemented as Terraform design only.

The Azure VM, Bastion, Defender for Servers, and JIT services were not deployed because the project maintains a zero-cost requirement.

The purpose of this section is to demonstrate secure compute architecture and Infrastructure as Code without creating unnecessary paid resources.

## SC-500 Mapping