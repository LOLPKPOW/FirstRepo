# Connect to Azure AD
Connect-AzureAD

# Get all users
$users = Get-AzureADUser -All $true -Filter "UserType eq 'Member'"

# Create a list to store users with errors
$usersWithErrors = @()

$csvFilePath

# Update telephone number for each user
foreach ($user in $users) {
    try {
        # Update the telephone number
        $user.TelephoneNumber = "877.550.5059"

        # Save the changes
        Set-AzureADUser -ObjectId $user.ObjectId -UserPrincipalName $user.UserPrincipalName -TelephoneNumber $user.TelephoneNumber

        Write-Host "Updated telephone number for $($user.UserPrincipalName)"
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
