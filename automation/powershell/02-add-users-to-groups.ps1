Import-Module Microsoft.Graph.Groups
Import-Module Microsoft.Graph.Users

# Load the canonical sanitized identity dataset.
$AutomationRoot = Split-Path $PSScriptRoot -Parent
$CsvPath = Join-Path $AutomationRoot "identity-data\employees.csv"

if (-not (Test-Path $CsvPath)) {
    throw "Identity data file was not found: $CsvPath"
}

$Users = Import-Csv $CsvPath

foreach ($User in $Users) {
    Write-Host ""
    Write-Host "Processing $($User.FirstName) $($User.LastName)..." -ForegroundColor Cyan

    # Find the group
    $Group = Get-MgGroup -Filter "displayName eq '$($User.Group)'"

    if (-not $Group) {
        Write-Host "❌ Group not found: $($User.Group)" -ForegroundColor Red
        continue
    }

    # Find the user
    $AzureUser = Get-MgUser -Filter "userPrincipalName eq '$($User.UserPrincipalName)'"

    if (-not $AzureUser) {
        Write-Host "❌ User not found: $($User.UserPrincipalName)" -ForegroundColor Red
        continue
    }

    try {
        New-MgGroupMemberByRef `
            -GroupId $Group.Id `
            -BodyParameter @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($AzureUser.Id)"
        }

        Write-Host "✅ Added to $($User.Group)" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ Already a member or another error occurred." -ForegroundColor Yellow
    }
}
