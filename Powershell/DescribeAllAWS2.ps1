# Set the AWS region
$AWS_REGION = Read-Host "Enter AWS region (i.e. us-east-2)"

# Initialize an array to store the tags to display
$tagsToDisplay = @()

# Prompt user to enter tags until "Done" or "All" is entered
while ($true) {
    $tag = Read-Host "Enter a tag to display (type 'Done' to finish, 'All' for all tags)"
    if ($tag -eq "Done") {
        break
    } elseif ($tag -eq "All") {
        $tagsToDisplay = "All"
        break
    }
    $tagsToDisplay += $tag
}

# Get all EC2 instances
$instances = aws ec2 describe-instances --region $AWS_REGION | ConvertFrom-Json

# Initialize an array to store instances with the specified tags
$taggedInstances = @()

# Loop through each instance
foreach ($reservation in $instances.Reservations) {
    foreach ($instance in $reservation.Instances) {
        # Initialize a hashtable to store instance details and tag values
        $instanceDetails = @{
            InstanceId = $instance.InstanceId
        }

        # Check if the instance has tags
        if ($instance.Tags) {
            if ($tagsToDisplay -eq "All") {
                # Add all tags to the instance details
                foreach ($tag in $instance.Tags) {
                    $instanceDetails[$tag.Key] = $tag.Value
                }
            } else {
                # Initialize all specified tags with "NA"
                foreach ($tag in $tagsToDisplay) {
                    $instanceDetails[$tag] = "NA"
                }

                # Loop through tags to find the specified tags
                foreach ($tag in $instance.Tags) {
                    if ($tagsToDisplay -contains $tag.Key) {
                        $instanceDetails[$tag.Key] = $tag.Value
                    }
                }
            }
        }

        # Add the instance details to the array of tagged instances
        $taggedInstances += [PSCustomObject]$instanceDetails
    }
}

# Output instances with the specified tags
$csvname = (Read-Host "Choose a file name to save exported csv")
if ($taggedInstances) {
    Write-Host "Instances with specified tags:"
    $taggedInstances | Format-Table -AutoSize   # Display results in a table
    $taggedInstances | Export-Csv -Path $csvname -NoTypeInformation
    Write-Host ("Results exported to: " + $csvname)
} else {
    Write-Host "No instances found with the specified tags."
}