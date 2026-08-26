Import-Module Microsoft.Graph.Users

$Users = Import-Csv ".\data\employees.csv"




$SecureInitialPassword = Read-Host "Enter the temporary user password" -AsSecureString
$InitialPassword = [System.Net.NetworkCredential]::new("", $SecureInitialPassword).Password

foreach ($User in $Users) {

    $Existing = Get-MgUser -Filter "userPrincipalName eq '$($User.UserPrincipalName)'"

    if ($Existing) {
        Write-Host "$($User.UserPrincipalName) already exists." -ForegroundColor Yellow
        continue
    }

    $Password = @{
        Password                      = $InitialPassword
        ForceChangePasswordNextSignIn = $true
    }

    New-MgUser `
        -DisplayName "$($User.FirstName) $($User.LastName)" `
        -GivenName $User.FirstName `
        -Surname $User.LastName `
        -UserPrincipalName $User.UserPrincipalName `
        -MailNickname (($User.FirstName + "." + $User.LastName).ToLower()) `
        -Department $User.Department `
        -JobTitle $User.JobTitle `
        -OfficeLocation $User.Office `
        -AccountEnabled `
        -PasswordProfile $Password

    Write-Host "Created $($User.FirstName) $($User.LastName)" -ForegroundColor Green

}