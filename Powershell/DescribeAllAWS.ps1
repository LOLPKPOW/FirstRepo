# Set the AWS region
$AWS_REGION = Read-Host "Enter AWS region (i.e. us-east-2)"

# Get all EC2 instances
$instances = aws ec2 describe-instances --region $AWS_REGION | ConvertFrom-Json

# Initialize an array to store instances with the specified tags
$taggedInstances = @()

# Loop through each instance
foreach ($reservation in $instances.Reservations) {
    foreach ($instance in $reservation.Instances) {
        # Initialize variables to store instance ID and tag values
        $instanceId = $instance.InstanceId
        $instanceName = "NA"
        $domain = "NA"
        $lob = "NA"
        $owner = "NA"
        $application = "NA"
        $cloudRangerPower = "NA"

        # Check if the instance has tags
        if ($instance.Tags) {
            # Loop through tags to find the specified tags
            foreach ($tag in $instance.Tags) {
                switch ($tag.Key) {
                    "Name" { $instanceName = $tag.Value }
                    "Domain" { $domain = $tag.Value }
                    "LOB" { $lob = $tag.Value }
                    "Owner" { $owner = $tag.Value }
                    "Application" { $application = $tag.Value }
                    "CloudRangerPower" { $cloudRangerPower = $tag.Value }
                }
            }
        }

        # Add the instance to the array of tagged instances
        $taggedInstances += [PSCustomObject]@{
            InstanceId = $instanceId
            Name = $instanceName
            Domain = $domain
            LOB = $lob
            Owner = $owner
            Application = $application
            CloudRangerPower = $cloudRangerPower
        }
    }
}

# Output instances with the specified tags
if ($taggedInstances) {
    Write-Host "Instances with specified tags:"
    $taggedInstances | Format-Table -AutoSize   # Display results in a table
    $taggedInstances | Export-Csv -Path "TaggedInstances.csv" -NoTypeInformation
    Write-Host "Results exported to: TaggedInstances.csv"
} else {
    Write-Host "No instances found with the specified tags."
}