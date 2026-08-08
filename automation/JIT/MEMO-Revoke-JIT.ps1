param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$Role,

    [Parameter(Mandatory = $true)]
    [string]$Scope
)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " MEMO - REVOKE TEMPORARY PRIVILEGED ACCESS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Group : $GroupName"
Write-Host "Role  : $Role"
Write-Host "Scope : $Scope"
Write-Host ""

# Find the Entra security group
$Group = Get-AzADGroup -DisplayName $GroupName -ErrorAction Stop

if (-not $Group) {
    Write-Error "Group '$GroupName' was not found."
    exit 1
}

Write-Host "Resolved group:" -ForegroundColor Green
Write-Host "  Name : $($Group.DisplayName)"
Write-Host "  ID   : $($Group.Id)"
Write-Host ""

# Check whether the RBAC assignment exists
$Assignment = Get-AzRoleAssignment `
    -ObjectId $Group.Id `
    -RoleDefinitionName $Role `
    -Scope $Scope `
    -ErrorAction SilentlyContinue

if (-not $Assignment) {
    Write-Host "No matching RBAC assignment exists." -ForegroundColor Yellow
    Write-Host "Nothing to revoke."
    exit 0
}

Write-Host "Existing privileged assignment found:" -ForegroundColor Yellow
$Assignment |
Select-Object DisplayName, RoleDefinitionName, ObjectId, Scope |
Format-List

Write-Host ""
Write-Host "Revoking temporary privileged access..." -ForegroundColor Red

Remove-AzRoleAssignment `
    -ObjectId $Group.Id `
    -RoleDefinitionName $Role `
    -Scope $Scope `
    -ErrorAction Stop

Write-Host ""
Write-Host "SUCCESS: Temporary privileged access revoked." -ForegroundColor Green
Write-Host ""