# Connect to Azure AD
Connect-AzureAD

# Get all users
$users = Get-AzureADUser -All $true | Where-Object {
  $_.UserType -eq 'Member' -and $_.Mobile -match '\(\d{3}\) \d{3}-\d{4}'
  }

$csvFilePath

# Create a list to store users with errors
$usersWithErrors = @()

foreach ($user in $users) {
    try {
        # Replace hyphens with periods in the telephone number
        $newTelephoneNumber = $user.Mobile -replace '[\(\)]', ''
        $newTelephoneNumber = $newTelephoneNumber -replace ' ', '.'
        $newTelephoneNumber = $newTelephoneNumber -replace '-', '.'

        # Update the telephone number
        $user.Mobile = $newTelephoneNumber
                # Save the changes
        Set-AzureADUser -ObjectId $user.ObjectId -UserPrincipalName $user.UserPrincipalName -Mobile $user.Mobile

        Write-Host "Updated mobile telephone number for $($user.UserPrincipalName)"
    }
    catch {
        # Handle errors
        Write-Host "Error updating telephone number for $($user.UserPrincipalName): $_"
        
        # Add the user to the list of users with errors
        $usersWithErrors += $user
    }
}
# Write users with errors to a file
$usersWithErrors | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "Script execution completed. Users with errors written to UsersWithErrors.csv."