# powershell-ad-export.ps1
# Simulates Active Directory user change log export

# Create mock AD user changes
$UserChanges = @(
    [PSCustomObject]@{Username="jdoe"; ChangeType="Created"; Timestamp=(Get-Date).AddMinutes(-45)},
    [PSCustomObject]@{Username="asmith"; ChangeType="Password Reset"; Timestamp=(Get-Date).AddMinutes(-30)},
    [PSCustomObject]@{Username="mbrown"; ChangeType="Group Membership Added: IT_Admins"; Timestamp=(Get-Date).AddMinutes(-15)},
    [PSCustomObject]@{Username="twilliams"; ChangeType="Account Disabled"; Timestamp=(Get-Date).AddMinutes(-5)}
)

# Export to CSV
$ExportPath = "$env:USERPROFILE\Desktop\AD_ChangeLog.csv"
$UserChanges | Export-Csv -Path $ExportPath -NoTypeInformation

Write-Host "AD Change log exported to $ExportPath"
