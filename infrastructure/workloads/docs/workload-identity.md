# MEMO Workload Identity

## Problem

Applications require access to cloud resources, but storing client secrets in
source code, images, configuration files, or pipelines creates avoidable
credential risk.

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

No application receives Contributor, Owner, or subscription-administrator
access simply because it needs to read one protected resource. Every workload
permission must use the smallest practical role and scope.

The same model can be extended to Storage, databases, and monitoring by adding
resource-specific data-plane roles instead of broad management-plane access.

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

## Example access decision

An application that only reads blobs should receive `Storage Blob Data Reader`
at the required storage scope. It should not receive Contributor or Owner.
