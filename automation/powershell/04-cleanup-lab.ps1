$Users = Import-Csv ".\data\employees.csv"

foreach ($User in $Users) {
    Remove-MgUser `
        -UserId $User.UserPrincipalName `
        -Confirm:$false
}