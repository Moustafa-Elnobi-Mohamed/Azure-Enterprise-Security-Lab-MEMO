# Day 11: Secure Compute and Cloud Container Security

Today I combined secure compute architecture with cloud container security.

Instead of spending time deploying another VM that I already know how to configure, I focused on the security controls around compute and then moved into a real Azure Container Apps deployment.

## Secure Compute Architecture

The secure VM design included:

* No public IP
* SSH key authentication
* Password authentication disabled
* Secure Boot
* vTPM
* Trusted Launch concepts
* System-assigned managed identity
* Private network placement
* NSG-based management restrictions

The management NSG was reviewed and confirmed to allow:

* RDP on TCP 3389 only from `10.10.3.0/24`
* SSH on TCP 22 only from `10.10.3.0/24`

This means administrative access is restricted to the dedicated management subnet instead of being exposed to the public internet.

I also reviewed Just-in-Time access and Defender for Servers as production security controls, but did not enable them because the project has a zero-cost requirement.

## Azure Container Apps

I then moved from traditional compute into containerized workloads.

A new Azure Container Apps environment was created under:

`MEMO-RG-Containers`

The application deployed was:

`memo-secure-app`

The application runs on the Azure Container Apps Consumption profile.

## Cost Controls

The container was configured with:

```text
CPU: 0.25 vCPU
Memory: 0.5 GiB
Minimum replicas: 0
Maximum replicas: 1
Workload profile: Consumption
```

Setting the minimum replica count to zero allows the workload to scale down when it is not being used.

This keeps the lab inside the zero-cost target while still providing a real cloud deployment.

## Ingress Security

External ingress was enabled so the application could be tested from the internet.

The configuration was verified as:

```text
External ingress: True
Allow insecure: False
Target port: 80
```

The Azure Container Apps ingress layer provides the public HTTPS endpoint while insecure HTTP access is disabled.

## Workload Identity

The Container App was assigned a system-assigned managed identity.

Principal ID:

`b6......21`

This gives the containerized workload its own identity in Microsoft Entra ID.

Instead of storing Azure credentials inside the container or application configuration, the workload can authenticate using its managed identity.

## Least-Privilege RBAC

The managed identity was granted:

`Key Vault Secrets User`

on:

`MEMO-KV-SECURITY`

The role was scoped directly to the Key Vault.

The workload was not granted:

* Owner
* Contributor
* Key Vault Administrator

This keeps the permissions limited to the specific capability required by the application.

The final identity path is:

```text
memo-secure-app
        |
        v
System-Assigned Managed Identity
        |
        v
Microsoft Entra ID
        |
        v
Azure RBAC
        |
        v
Key Vault Secrets User
        |
        v
MEMO-KV-SECURITY
```

## NHI Security

This was another practical example of non-human identity security.

The identity belongs to the workload instead of a person.

The same least-privilege rules used for human identities also need to be applied to applications, services, automation, containers, and agents.

## Security Architecture

```text
Internet
   |
 HTTPS
   |
Azure Container Apps
memo-secure-app
   |
   +-- Consumption profile
   +-- Scale to zero
   +-- Max one replica
   +-- System Managed Identity
   |
   v
Microsoft Entra ID
   |
 Azure RBAC
   |
   v
MEMO-KV-SECURITY
Key Vault Secrets User
```

## What I Learned

The main lesson today was that securing compute is not only about protecting a VM.

Modern cloud environments contain many different compute models.

Traditional VMs need boot security, restricted management access, strong authentication, and network segmentation.

Container workloads need many of the same principles applied differently.

For the Container App, the important controls became:

* HTTPS
* reduced resource consumption
* controlled scaling
* workload identity
* no hardcoded Azure credentials
* narrowly scoped RBAC

This also made the relationship between workload identity and non-human identity much clearer.

## SC-500 Mapping

* Secure Azure compute
* Trusted Launch
* Secure Boot
* vTPM
* Administrative network security
* Managed identities
* Workload identities
* Azure RBAC
* Least privilege
* Container security
* Azure Container Apps
* Application ingress security
* Key Vault access
* Non-human identity security
* Cloud cost governance

## Outcome

Day 11 moved the MEMO Foundation project from traditional compute security into cloud-native container security.

The project now includes both secure compute architecture and a live cloud container workload protected through HTTPS, managed identity, least-privilege RBAC, and controlled scaling.
