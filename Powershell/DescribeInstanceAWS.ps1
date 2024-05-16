# Set the AWS region
$AWS_REGION = Read-Host "Enter AWS region (i.e. us-east-2)"

# Get all EC2 instances
$instances = aws ec2 describe-instances --region $AWS_REGION | ConvertFrom-Json

# Initialize an array to store instances with non-standard severity or no severity tag
$nonStandardSeverityInstances = @()

# Loop through each instance
foreach ($reservation in $instances.Reservations) {
    foreach ($instance in $reservation.Instances) {
        # Initialize variables to store instance ID and name
        $instanceId = $instance.InstanceId
        $instanceName = ""

        # Initialize variable to store severity tag value
        $severityTag = ""

        # Check if the instance has tags
        if ($instance.Tags) {
            # Loop through tags to find the "Name" and "Severity" tags
            foreach ($tag in $instance.Tags) {
                if ($tag.Key -eq "Name") {
                    $instanceName = $tag.Value
                }
                if ($tag.Key -eq "Severity") {
                    $severityTag = $tag.Value
                }
            }
        }

        # Add the instance to the array if severity tag is empty or non-standard
        if (-not $severityTag -or $severityTag -notin ("Low", "Medium", "High")) {
            # Add the instance to the array of instances with non-standard severity or no severity tag
            $nonStandardSeverityInstances += [PSCustomObject]@{
                InstanceId = $instanceId
                InstanceName = $instanceName
                CurrentSeverity = $severityTag
            }
        }
    }
}

# Output instances with non-standard severity or no severity tag
if ($nonStandardSeverityInstances) {
    Write-Host "Instances with non-standard severity or no severity tag:"
    $nonStandardSeverityInstances | Format-Table -AutoSize   # Display results in a table
    $nonStandardSeverityInstances | Export-Csv -Path "NonStandardSeverityInstances.csv" -NoTypeInformation
    Write-Host "Results exported to: NonStandardSeverityInstances.csv"
} else {
    Write-Host "No instances found with non-standard severity or no severity tag."
}
