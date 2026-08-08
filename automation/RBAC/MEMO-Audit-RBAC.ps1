Write-Host "====================================="
Write-Host " MEMO RBAC SECURITY AUDIT"
Write-Host "====================================="

$Assignments = Get-AzRoleAssignment

$Assignments |
    Select-Object `
        DisplayName,
        ObjectType,
        RoleDefinitionName,
        Scope |
    Sort-Object Scope, RoleDefinitionName |
    Format-Table -AutoSize