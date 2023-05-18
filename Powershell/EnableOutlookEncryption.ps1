## Import Azure Information Protection Service
Import-Module AipService -confirm
## Connect Exchange Online
Connect-ExchangeOnline
## Can pull the current config if you'd like
# Get-IRMConfiguration
## Set Information Rights Management for Azure Rights Management to True
Set-IRMConfiguration -AzureRMSLicesingEnabled $true
## Set Information Rights Manage for Internal Licensing to True (don't believe it's necessary but can try if it doesn't work properly.
# Set-IRMConfiguration -InternalLicensingEnabled $true
## Enable Azure Information Protection Service
Enable-AipService
## The following lines are to pull the proper licensing location from the config
$RMSConfig = Get-AadrmConfiguration
$LicenseUri = $RMSConfig.LicensingIntranetDistributionPointUrl
Set-IRMConfiguration -LicensingLocation $LicenseUri
## This is to test for a "PASS" with a user entered email
$TestEmail = Write-Host("Enter an email to run the test process")
Test-IRMConfiguration -sender $TestEmail