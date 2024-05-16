# Set the AWS region
$AWS_REGION = Read-Host "Enter AWS region (e.g., us-east-1)"

# Define the tag key and value
$TagKey = Read-Host "Enter Tag Key"
$TagValue = Read-Host "Enter Tag Value"

# Define CSV file and Path
$CSVPath = Read-Host "Enter path and .csv file name (e.g., C:\temp\File.csv)"

# Read the CSV file and add or modify tags for each EC2 instance
Get-Content $CSVPath | ForEach-Object {
    # Split the instance names by comma (if multiple names are provided)
    $InstanceNames = $_ -split ","
    
    foreach ($InstanceName in $InstanceNames) {
        # Get the instance ID for the current EC2 instance name
        $InstanceInfo = aws ec2 describe-instances --region $AWS_REGION --filters "Name=tag:Name,Values=$InstanceName" --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Severity`].Value]' --output text
        
        # Check if the instance info is empty (i.e. instance name doesn't exist)
        if ([string]::IsNullOrEmpty($InstanceInfo)) {
            Write-Host "Instance '$InstanceName' does not exist."
            # Write data to file
            $OutputData = [PSCustomObject]@{
                InstanceName = $InstanceName
                TagKey = $TagKey
                TagValue = $TagValue
                Status = "Skipped"
                Reason = "Instance Doesn't Exist"
            }
            $OutputData | Export-Csv -Path "tagaddfailed.csv" -Append -NoTypeInformation
            continue
        }
        
        # Extract the instance ID and current tag value from the instance info
        $InstanceId, $CurrentTag = $InstanceInfo -split "`t"
        
        # Check if the specified tag key already exists for the EC2 instance
        if ($CurrentTag -eq $null) {
            # If the tag doesn't exist, add it
            aws ec2 create-tags --resources $InstanceId --tags "Key=$TagKey,Value=$TagValue" --region $AWS_REGION
            Write-Host "Successfully added tag '$TagKey' with value '$TagValue' for $InstanceName"
            $OutputData = [PSCustomObject]@{
                InstanceName = $InstanceName
                TagKey = $TagKey
                TagValue = $TagValue
                Status = "Success"
            }
            $OutputData | Export-Csv -Path "tagaddsuccess.csv" -Append -NoTypeInformation
        } elseif ($CurrentTag -ne $TagValue) {
            # If the tag exists and its value is different from the new value, modify it
            aws ec2 create-tags --resources $InstanceId --tags "Key=$TagKey,Value=$TagValue" --region $AWS_REGION
            Write-Host "Changed tag '$TagKey' from '$CurrentTag' to '$TagValue' for $InstanceName"
            $OutputData = [PSCustomObject]@{
                InstanceName = $InstanceName
                TagKey = $TagKey
                TagValue = $TagValue
                Status = "Modified"
                PreviousValue = $CurrentTag
            }
            $OutputData | Export-Csv -Path "tagmodified.csv" -Append -NoTypeInformation
        } else {
            # If the tag exists and its value is the same as the new value, skip
            Write-Host "Tag '$TagKey' already exists with value '$TagValue' for $InstanceName. Skipping..."
            $OutputData = [PSCustomObject]@{
                InstanceName = $InstanceName
                TagKey = $TagKey
                TagValue = $TagValue
                Status = "Skipped"
                Reason = "Tag Exists"
            }
            $OutputData | Export-Csv -Path "tagskipped.csv" -Append -NoTypeInformation
        }
    }
}
Write-Host "Process Complete"
