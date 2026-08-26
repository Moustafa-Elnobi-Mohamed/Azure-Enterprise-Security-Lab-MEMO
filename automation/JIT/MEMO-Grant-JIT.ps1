param(
    [Parameter(Mandatory=$true)]
    [string]$GroupName,

    [Parameter(Mandatory=$true)]
    [string]$Role,

    [Parameter(Mandatory=$true)]
    [string]$Scope,

    [int]$DurationMinutes = 30
)

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " MEMO - TEMPORARY PRIVILEGED ACCESS REQUEST" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$Group = Get-AzADGroup -DisplayName $GroupName -ErrorAction Stop

if (-not $Group) {
    throw "Group '$GroupName' was not found."
}

Write-Host "Group : $($Group.DisplayName)"
Write-Host "ID    : $($Group.Id)"
Write-Host "Role  : $Role"
Write-Host "Scope : $Scope"
Write-Host "Time  : $DurationMinutes minutes"
Write-Host ""

# Check existing assignment
$Existing = Get-AzRoleAssignment `
    -ObjectId $Group.Id `
    -RoleDefinitionName $Role `
    -Scope $Scope `
    -ErrorAction SilentlyContinue

if ($Existing) {
    Write-Host "Assignment already exists." -ForegroundColor Yellow
    exit 0
}

Write-Host "Granting temporary privileged access..." -ForegroundColor Yellow

New-AzRoleAssignment `
    -ObjectId $Group.Id `
    -ObjectType Group `
    -RoleDefinitionName $Role `
    -Scope $Scope `
    -Description "MEMO simulated JIT access - $DurationMinutes minutes"

$Start = Get-Date
$Expiration = $Start.AddMinutes($DurationMinutes)

Write-Host ""
Write-Host "ACCESS GRANTED" -ForegroundColor Green
Write-Host "Start     : $Start"
Write-Host "Expires   : $Expiration"
Write-Host ""

# Write a local audit record outside the tracked repository inventory.
$RepositoryRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$LogDirectory = Join-Path $RepositoryRoot ".local\logs"
$LogPath = Join-Path $LogDirectory "MEMO-JIT.log"

New-Item -ItemType Directory -Force -Path $LogDirectory | Out-Null

@"
[$Start]
JIT GRANT
Group=$GroupName
Role=$Role
Scope=$Scope
DurationMinutes=$DurationMinutes
Expiration=$Expiration
"@ | Add-Content $LogPath

Write-Host "Audit entry written to $LogPath" -ForegroundColor Cyan
