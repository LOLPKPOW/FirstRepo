## Install Azure Information Protection Service
Write-Host "Installing Azure Information Protection Service module"
Install-Module AipService -confirm
## Connect Exchange Online
Write-Host "Connect to Exchange Online"
Connect-ExchangeOnline
## Can pull the current config if you'd like
Write-Host "Pulling current IRM Configuration"
Get-IRMConfiguration
## Set Information Rights Management for Azure Rights Management to True
Write-Host "Set IRM Confirguartion for Azure RMS to Enabled"
Set-IRMConfiguration -AzureRMSLicensingEnabled: $true
## Set Information Rights Manage for Internal Licensing to True (don't believe it's necessary but can try if it doesn't work properly.
Write-Host "Set IRM Configurationg for Internal Licensing to Enabled"
Set-IRMConfiguration -InternalLicensingEnabled: $true
## Connect to Azure Information Protection Service
Write-Host "Connect to AIP Service"
Connect-AipService
## Enable Azure Information Protection Service
Write-Host "Set Azure Information Protection Service to Enabled"
Enable-AipService
## The following lines are to pull the proper licensing location from the config
Write-Host "Pulling current Licensing Intranet Distribution Point URL"
$RMSConfig = Get-AadrmConfiguration
$LicenseUri = $RMSConfig.LicensingIntranetDistributionPointUrl
Write-Host "Enable the appropriate Licensing Location using the Licensing Intranet Distribution Point URL"
Set-IRMConfiguration -LicensingLocation $LicenseUri
## This is to test for a "PASS" with a user entered email
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host "Process compelte. Enter e-mail below for testing"
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
$TestEmail = Read-Host("Enter an email to run the test process")
Test-IRMConfiguration -sender $TestEmail
Read-Host -Prompt "Press Enter to exit"