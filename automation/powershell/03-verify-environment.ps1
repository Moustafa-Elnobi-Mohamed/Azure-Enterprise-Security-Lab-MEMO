Get-MgUser |
Select DisplayName, Department, JobTitle

Get-MgGroup |
Select DisplayName

$Group = Get-MgGroup -Filter "displayName eq 'MEMO-GRP-Cloud-Admins'"

Get-MgGroupMember `
    -GroupId $Group.Id