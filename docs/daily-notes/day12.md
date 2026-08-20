# Day 12: Kubernetes Security

## Goal

Today I moved from securing a Docker container in Azure Container Apps to understanding how the same workload should be secured in Kubernetes.

I had one strict requirement: no spending money.

I did not deploy AKS because its worker nodes, networking, monitoring, and related resources could create charges. Instead, I built the Kubernetes manifests in my repository and deployed them to a temporary browser-based Kubernetes cluster.

This gave me real hands-on evidence without creating paid Azure resources.

## What I built

I created the following files inside:

```text
infrastructure/kubernetes/
```

* `namespace.yaml`
* `service-account.yaml`
* `configmap.yaml`
* `secret-example.yaml`
* `deployment.yaml`
* `service.yaml`
* `rbac.yaml`
* `network-policy.yaml`

Together, these files created a secured Kubernetes workload for `memo-secure-app`.

## Namespace isolation

I created a dedicated namespace called:

```text
memo-app
```

This separates the application from other Kubernetes workloads and gives me a boundary for RBAC, Pod Security, and NetworkPolicy.

I configured the namespace to enforce the restricted Pod Security standard.

The namespace was set to:

* Enforce restricted policies
* Audit restricted-policy violations
* Warn about restricted-policy violations

This means Kubernetes can reject workloads that do not meet the required security baseline.

## Container hardening

I used:

```text
nginxinc/nginx-unprivileged:alpine
```

instead of the standard NGINX image because it is designed to run without root privileges.

The deployment included the following security controls:

* `runAsNonRoot: true`
* UID and GID set to `101`
* Privileged mode disabled
* Privilege escalation disabled
* All Linux capabilities dropped
* `RuntimeDefault` seccomp profile
* Read-only root filesystem
* Memory-backed `/tmp` volume
* CPU requests and limits
* Memory requests and limits
* Liveness probe
* Readiness probe

I also disabled automatic Kubernetes service-account token mounting.

```yaml
automountServiceAccountToken: false
```

The application does not need to control the Kubernetes API, so it should not automatically receive an API credential.

## Private service exposure

I created a Kubernetes service using:

```text
ClusterIP
```

I did not use:

```text
LoadBalancer
```

This keeps the service private inside the cluster and avoids accidentally provisioning a public cloud load balancer.

The application listens on container port `8080`, while the private service exposes port `80` internally.

## Configuration and secrets

I used a ConfigMap for non-sensitive application settings such as:

* Environment name
* Project name
* Security mode

I also created an example Kubernetes Secret, but it contains no real credentials.

The example exists only to demonstrate the structure of a Kubernetes Secret. Real credentials should never be committed to Git.

The production design uses:

```text
Kubernetes pod
    -> Kubernetes service account
    -> Microsoft Entra Workload ID
    -> User-assigned managed identity
    -> Azure Key Vault
```

This avoids storing Azure client secrets in application code or Kubernetes YAML.

## Kubernetes RBAC

I created two service accounts.

### Workload service account

```text
memo-workload-sa
```

This identity is used by the application.

It receives no Kubernetes RBAC permissions because the application does not need to list, create, modify, or delete Kubernetes resources.

### Auditor service account

```text
memo-auditor-sa
```

This identity received a namespace-scoped read-only role.

It can read:

* Pods
* Services
* ConfigMaps
* Events
* Deployments
* ReplicaSets
* NetworkPolicies

It cannot:

* Read secrets
* Create resources
* Modify resources
* Delete resources
* Access cluster-wide resources
* Receive cluster-admin privileges

This created a practical least-privilege separation between the application and the security auditor.

## Network security

I started with a default-deny NetworkPolicy for ingress and egress.

This means traffic is blocked unless I explicitly allow it.

I added two exceptions:

* Internal access to `memo-secure-app` on TCP port `8080`
* DNS resolution through TCP and UDP port `53`

I did not allow general outbound internet access.

The final network model was:

```text
Default ingress: deny
Default egress: deny
Internal application traffic: allow
DNS: allow
Outbound HTTP: deny
Public load balancer: none
```

## Cloud deployment

I used a temporary browser-based Kubernetes playground.

This gave me a real two-node Kubernetes cluster without:

* Installing a local cluster
* Creating AKS
* Connecting to my Azure subscription
* Entering payment information
* Creating permanent cloud resources

The deployment completed successfully.

The final status showed:

```text
Pod status: Running
Ready: 1/1
Restarts: 0
Service type: ClusterIP
Network policies: 3
```

## Troubleshooting lesson

My first Git commit created the YAML filenames, but the files were empty because I had not pressed `Ctrl+S` before committing.

The Git push succeeded, but the temporary cloud environment showed:

```text
0 deployment.yaml
0 namespace.yaml
0 network-policy.yaml
```

When I attempted to apply the namespace, Kubernetes returned:

```text
error: no objects passed to apply
```

I compared the local, staged, and committed Git hashes and confirmed that the saved local files were different from the committed versions.

I then staged the saved files, committed the actual contents, pushed the correction, and pulled the updated commit into the temporary cluster.

After the correction, the cloud environment showed 255 total lines across the manifests.

The main lesson was that a successful Git push does not prove the intended content was saved. I should verify:

* File sizes
* Git status
* Staged changes
* Line counts
* The committed file contents

## Security validation

I did not stop after deploying the manifests. I tested the controls.

### Non-root execution

The running container returned:

```text
uid=101(nginx) gid=101(nginx)
```

This confirmed that the application was not running as root.

### Privilege escalation

The deployment returned:

```text
false
```

for `allowPrivilegeEscalation`.

### Read-only filesystem

I attempted to create:

```text
/security-test
```

inside the container.

The operation failed with:

```text
Read-only file system
```

This confirmed that the root filesystem could not be modified.

### Service-account token

I checked for the standard Kubernetes service-account token directory.

The result was:

```text
PASS: no service-account token mounted
```

### Workload RBAC

I tested whether `memo-workload-sa` could list pods.

Result:

```text
no
```

I tested whether it could read secrets.

Result:

```text
no
```

### Auditor RBAC

I tested whether `memo-auditor-sa` could list pods.

Result:

```text
yes
```

I tested whether it could read secrets.

Result:

```text
no
```

I tested whether it could delete deployments.

Result:

```text
no
```

This confirmed that the read-only auditor role worked correctly.

### Pod Security enforcement

I deliberately attempted to deploy an insecure NGINX pod without the required security context.

Kubernetes rejected it because it:

* Allowed privilege escalation
* Did not drop all capabilities
* Did not enforce non-root execution
* Did not configure an approved seccomp profile

I then checked for the rejected pod and received:

```text
NotFound
```

This proved that restricted Pod Security was being enforced, not just documented.

### NetworkPolicy enforcement

I first confirmed that the application responded locally on port `8080`.

I then attempted an outbound HTTP connection to `example.com`.

The result was:

```text
PASS: outbound HTTP blocked by default-deny egress
```

This confirmed that the workload could run normally while unnecessary external communication remained blocked.

## Workload identity design

For a production AKS deployment, I would connect:

```text
memo-workload-sa
```

to the existing MEMO user-assigned managed identity through Microsoft Entra Workload ID.

The federated identity subject would be:

```text
system:serviceaccount:memo-app:memo-workload-sa
```

The managed identity would retain only the required Azure role:

```text
Key Vault Secrets User
```

scoped to:

```text
MEMO-KV-SECURITY
```

This would allow the application to retrieve approved secrets from Key Vault without storing a client secret in Git or Kubernetes.

I documented this as the production architecture. I did not claim that it was deployed inside the temporary Kubernetes playground.

## Cost decision

I intentionally did not deploy:

* AKS
* Azure worker nodes
* Azure Container Registry
* Defender for Containers
* Log Analytics for Kubernetes
* Microsoft Sentinel ingestion for Kubernetes
* A public cloud load balancer

The temporary cluster automatically expires.

The permanent deliverables are:

* Kubernetes manifests
* Deployment evidence
* Pod Security evidence
* Container-hardening evidence
* RBAC evidence
* NetworkPolicy evidence
* Workload identity architecture
* Kubernetes threat model
* Professional documentation

## SC-500 concepts covered

Day 12 covered:

* Kubernetes security
* Application-platform security
* Secure compute configuration
* Non-human identity security
* Managed and workload identity design
* Azure Key Vault access architecture
* Least-privilege RBAC
* Namespace isolation
* Restricted Pod Security
* Network segmentation
* Secrets management
* Infrastructure as code
* Container posture and runtime risks

## Final result

I finished Day 12 with a working hardened Kubernetes workload, real negative security testing, RBAC validation, network-policy enforcement, Pod Security enforcement, production workload-identity architecture, and no Azure spending.

The next phase is Day 13: Defender for Cloud, CSPM, recommendations, regulatory compliance, and workload-protection architecture without enabling paid Defender plans.
