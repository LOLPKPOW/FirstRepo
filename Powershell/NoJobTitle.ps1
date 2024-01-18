Connect-AzureAD

# Get users with a blank job title
$users = Get-AzureADUser -All $true | Where-Object { $_.JobTitle -eq $null -or $_.JobTitle -eq '' }

# Specify the path for the CSV file
$csvFilePath = Read-Host -prompt "Enter File save directory + File Name"

# Export users to CSV
$users | Select-Object DisplayName, UserPrincipalName, JobTitle | Export-Csv -Path $csvFilePath -NoTypeInformation

# Display a message indicating the completion
Write-Host "CSV file created: $csvFilePath"
