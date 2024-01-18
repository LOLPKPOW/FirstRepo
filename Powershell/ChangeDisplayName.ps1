# Connect to Azure AD
Connect-AzureAD

# Get all member users
$users = Get-AzureADUser -All $true -Filter "UserType eq 'Member'"

# Create a list to store users with errors
$usersWithErrors = @()

$csvFilePath = Read-Host -prompt "Enter File save directory + File Name"

# Update display name for each user
foreach ($user in $users) {
    try {
        # Construct the new display name
        $newDisplayName = "$($user.GivenName) $($user.Surname)"

        # Check if the job title contains 'Contractor'
        if ($user.JobTitle -like '*Contractor*') {
            $newDisplayName += " - C"
        }

        # Update the display name
        $user.DisplayName = $newDisplayName

        # Save the changes
        Set-AzureADUser -ObjectId $user.ObjectId -UserPrincipalName $user.UserPrincipalName -DisplayName $user.DisplayName

        Write-Host "Updated display name for $($user.UserPrincipalName)"
    }
    catch {
        # Handle errors
        Write-Host "Error updating display name for $($user.UserPrincipalName): $_"
        
        # Add the user to the list of users with errors
        $usersWithErrors += $user
    }
}

# Write users with errors to a file
$usersWithErrors | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "Script execution completed. Users with errors written to UsersWithErrors_DisplayName.csv."
