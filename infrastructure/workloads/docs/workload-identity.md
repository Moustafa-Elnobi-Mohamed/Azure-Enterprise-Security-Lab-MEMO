# MEMO Workload Identity

## Identity

MEMO-ID-Workload-App

## Type

User-assigned managed identity

## Purpose

Provides an Azure identity for application workloads without storing
credentials in source code or configuration files.

## Key Vault Access

Role:

Key Vault Secrets User

Scope:

MEMO-KV-SECURITY

## Security Decision

The workload receives read access to secrets only.

It does not receive:

- Owner
- Contributor
- Key Vault Administrator

This follows least privilege.

## Architecture

Application
    |
    v
MEMO-ID-Workload-App
    |
    v
Microsoft Entra ID
    |
    v
Azure RBAC
    |
    v
MEMO-KV-SECURITY