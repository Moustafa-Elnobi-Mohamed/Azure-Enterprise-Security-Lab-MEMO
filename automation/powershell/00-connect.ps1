# Connect to Microsoft Graph

Connect-MgGraph `
    -Scopes `
    User.ReadWrite.All,
Group.ReadWrite.All,
Directory.ReadWrite.All

Get-MgContext