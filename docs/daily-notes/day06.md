# Day 6: Network Security Foundation

Today I built the main MEMO network architecture.

The core VNet is:

```text
MEMO-VNET-CORE
10.10.0.0/16
```

I separated it into four subnets:

```text
MEMO-SUBNET-APP
10.10.1.0/24

MEMO-SUBNET-DATA
10.10.2.0/24

MEMO-SUBNET-MGMT
10.10.3.0/24

MEMO-SUBNET-SECURITY
10.10.4.0/24
```

The architecture became:

```text
                 MEMO-VNET-CORE
                   10.10.0.0/16
                         |
        +----------------+----------------+
        |                |                |
       APP              DATA             MGMT
  10.10.1.0/24     10.10.2.0/24     10.10.3.0/24
        |                |                |
    NSG-APP          NSG-DATA         NSG-MGMT
                         |
                     SECURITY
                    10.10.4.0/24
                         |
                   NSG-SECURITY
```

Then I created four NSGs and attached each one to its corresponding subnet.

The final custom rules included:

### APP

```text
HTTPS 443 from Internet
HTTP 80 from Internet
```

### DATA

```text
SQL 1433 from APP subnet
Internal VNet traffic
```

### MGMT

```text
RDP 3389 from MGMT subnet
SSH 22 from MGMT subnet
```

### SECURITY

```text
HTTPS 443 from VirtualNetwork
```

## Problems I faced

My NSG PowerShell script originally had multiple rules using the same priorities.

Azure rejected them with:

```text
SecurityRuleConflict
```

That taught me that priority is unique within the same NSG direction.

I cleaned the rules instead of piling more rules on top of the broken configuration.

Another problem happened when PowerShell temporarily could not resolve:

```text
management.azure.com
```

even though DNS and TCP 443 tests worked.

The Azure Portal showed that the resources existed, so I verified the environment instead of rebuilding the VNet.

## What I learned

Network segmentation is really about controlling trust.

APP should not automatically trust DATA.

MGMT should not automatically trust everything.

SECURITY should have its own zone.

The NSG is where those boundaries become enforceable.

---

