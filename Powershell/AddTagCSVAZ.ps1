# Define the tag key and value
$TagKey = Read-Host "Enter Tag Key"
$TagValue = Read-Host "Enter Tag Value"

# Define CSV file and Path
$CSVPath = Read-Host "Enter path and .csv file name (e.g., C:\temp\File.csv)"

# Function to authenticate to Azure
function LoginToAzure {
    Write-Host "Logging you in to Azure via web browser..."
    Start-Process "https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=1950a258-227b-4e31-a9cf-717495945fc2&redirect_uri=http://localhost" -Wait
    az login
}

# Authenticate to Azure
LoginToAzure

# Check if authentication was successful
$LoggedIn = az account show --query 'id' -o tsv
if (-not $LoggedIn) {
    Write-Host "Failed to authenticate to Azure. Please check your credentials and try again."
    exit
} else {
    Write-Host "Authentication to Azure successful."
}

# Function to prompt user to select a resource group
function Select-AzResourceGroup {
    $ResourceGroups = (az group list --query '[].name' -o tsv).Split("`n")
    Write-Host "Select an Azure resource group:"
    for ($i = 0; $i -lt $ResourceGroups.Count; $i++) {
        Write-Host "$($i + 1). $($ResourceGroups[$i])"
    }
    $choice = Read-Host "Enter the number of the resource group (or 'all' to process all resource groups)"
    if ($choice -eq 'all') {
        return $ResourceGroups
    } elseif ([int]::TryParse($choice, [ref]$null) -and $choice -ge 1 -and $choice -le $ResourceGroups.Count) {
        return $ResourceGroups[$choice - 1]
    } else {
        Write-Host "Invalid selection. Please try again."
        Select-AzResourceGroup
    }
}

# Get the list of Azure resource groups
$SelectedResourceGroup = Select-AzResourceGroup

# If a single resource group is selected, convert it to an array
if ($SelectedResourceGroup -isnot [array]) {
    $SelectedResourceGroup = @($SelectedResourceGroup)
}

# Read the CSV file and add tags to each Azure resource in the selected resource group(s)
foreach ($ResourceGroupName in $SelectedResourceGroup) {
    Get-Content $CSVPath | ForEach-Object {
        # Split the resource names by comma (if multiple names are provided)
        $ResourceNames = $_ -split ","
        
        foreach ($ResourceName in $ResourceNames) {
            # Get the Azure resource by name
            $Resource = az resource show --name $ResourceName --resource-group $ResourceGroupName --resource-type "Microsoft.Compute/virtualMachines" --query 'id' -o tsv 2>$null
            if (-not $Resource) {
                Write-Host "Resource '$ResourceName' does not exist in resource group '$ResourceGroupName'."
                continue
            }

            # Update the tags for the resource
            az tag update --resource-id $Resource --operation Merge --tags "$TagKey=$TagValue" | Out-Null

            # Output message based on tag addition success
            Write-Host "Successfully added tag '$TagKey' with value '$TagValue' for $ResourceName in resource group '$ResourceGroupName'."
        }
    }
}

Write-Host "Process completed."
