                         MEMO FOUNDATION
                               |
       +-----------------------+-----------------------+
       |                       |                       |
    IDENTITY                NETWORK                   DATA
       |                       |                       |
   Entra ID             MEMO-VNET-CORE            Key Vault
   RBAC                  10.10.0.0/16               |
   PIM/JIT                     |                    RBAC
       |                 +-----+-----+               |
       |                 |     |     |               |
       |                APP   DATA  MGMT          Secrets
       |                 |     |     |               |
       |                NSG   NSG   NSG              |
       |                       |                       |
       +-----------------------+-----------------------+
                               |
                         Azure Monitor
                               |
                        Log Analytics
                               |
                      Microsoft Sentinel
                               |
                              KQL
                               |
                      Analytics Rules
                               |
                       Defender Incident


                 INFRASTRUCTURE AS CODE
                          |
                      Terraform
                   /       |       \
             Networking  Key Vault  Storage
                                     |
                                Planned only
                              Zero-cost policy