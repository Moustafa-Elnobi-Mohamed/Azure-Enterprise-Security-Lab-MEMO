param(
    [Parameter(Mandatory)]
    [string]$GroupName,

    [Parameter(Mandatory)]
    [string]$Role,

    [Parameter(Mandatory)]
    [string]$Scope,

    [int]$DurationMinutes = 30
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host " MEMO JIT PRIVILEGED ACCESS WORKFLOW" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

$Group = Get-AzADGroup -DisplayName $GroupName

if ($null -eq $Group) {
    throw "Group '$GroupName' was not found."
}

Write-Host ""
Write-Host "Group: $GroupName"
Write-Host "Role: $Role"
Write-Host "Scope: $Scope"
Write-Host "Duration: $DurationMinutes minutes"
Write-Host ""

$StartTime = Get-Date
$ExpirationTime = $StartTime.AddMinutes($DurationMinutes)

Write-Host "Activating privileged access..." -ForegroundColor Yellow

New-AzRoleAssignment `
    -ObjectId $Group.Id `
    -ObjectType Group `
    -RoleDefinitionName $Role `
    -Scope $Scope

Write-Host ""
Write-Host "JIT ACCESS ACTIVATED" -ForegroundColor Green
Write-Host "Start: $StartTime"
Write-Host "Expires: $ExpirationTime"
Write-Host ""

$Log = [PSCustomObject]@{
    Project     = "MEMO"
    Group       = $GroupName
    Role        = $Role
    Scope       = $Scope
    StartTime   = $StartTime
    Expiration  = $ExpirationTime
    RequestedBy = (Get-AzContext).Account.Id
}

$RepositoryRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$LogDirectory = Join-Path $RepositoryRoot ".local\logs"
$LogPath = Join-Path $LogDirectory "MEMO-JIT-Audit.csv"

New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null

$Log | Export-Csv `
    $LogPath `
    -NoTypeInformation `
    -Append

Write-Host "Audit record written to $LogPath" -ForegroundColor Green
