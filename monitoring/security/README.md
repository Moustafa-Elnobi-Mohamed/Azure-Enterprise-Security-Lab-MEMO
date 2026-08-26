# Security Monitoring

This directory contains the KQL used for security baselining, hunting,
investigation, and dashboard views across Azure Activity, identity, Key Vault,
networking, storage, and database telemetry.

- [KQL library](KQL/)
- [Deployable Sentinel rules](../../detections/sentinel/rules/)

The KQL library supports analyst investigation. Deployable analytics-rule
definitions remain under `detections/` so queries and live detection artifacts
are not confused.
