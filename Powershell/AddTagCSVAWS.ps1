# Set the AWS region
$AWS_REGION = Read-Host "Enter AWS region (i.e. us-east-2)"

# Define the tag key and value
$TagKey = Read-Host "Enter Tag Key"
$TagValue = Read-Host "Enter Tag Value"

# Define CSV file and Path
$CSVPath = Read-Host "Enter path and .csv file name (i.e. C:\temp\File.csv)"

# Read the CSV file and add tags to each EC2 instance
Get-Content $CSVPath | ForEach-Object {
    # Split the instance names by comma (if multiple names are provided)
    $InstanceNames = $_ -split ","
    
    foreach ($InstanceName in $InstanceNames) {
        # Get the instance ID for the current EC2 instance name
        $InstanceInfo = aws ec2 describe-instances --region $AWS_REGION --filters "Name=tag:Name,Values=$InstanceName" --query 'Reservations[*].Instances[*].InstanceId' --output text
        
        # Check if the instance info is empty (i.e. instance name doesn't exist)
        if ([string]::IsNullOrEmpty($InstanceInfo)) {
            Write-Host "Instance '$InstanceName' does not exist."
            continue
        }
        
        # Extract the instance ID from the instance info
        $InstanceId = $InstanceInfo.Trim()
        
        # Check if the specified tag key already exists for the EC2 instance
        $ExistingTags = aws ec2 describe-tags --region $AWS_REGION --filters "Name=resource-id,Values=$InstanceId" "Name=key,Values=$TagKey" | ConvertFrom-Json
        
        # If the tag key already exists, skip adding the tag
        if ($ExistingTags.Tags) {
            Write-Host "Tag '$TagKey' already exists for $InstanceName. Skipping..."
            continue
        }
        
        # Add tags to the EC2 instance
        aws ec2 create-tags --resources $InstanceId --tags Key=$TagKey,Value=$TagValue --region $AWS_REGION
        
        # Check if the tags were successfully added
        $TagsAdded = (aws ec2 describe-tags --region $AWS_REGION --filters "Name=resource-id,Values=$InstanceId" "Name=key,Values=$TagKey" "Name=value,Values=$TagValue")
        
        # Output message based on tag addition success
        if ($TagsAdded) {
            Write-Host "Successfully added tag '$TagKey' with value '$TagValue' for $InstanceName"
        } else {
            Write-Host "Failed to add tag '$TagKey' with value '$TagValue' for $InstanceName"
        }
    }
}
