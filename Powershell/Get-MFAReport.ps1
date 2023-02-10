# Comment to remember Remote Execution Policy
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass


# Function to find Tenant ID
function GetCustID{
 $global:domain = Read-Host -prompt "Type the domain name"
 $global:tenantid = (Get-MsolPartnerContract -DomainName $domain | Select-Object TenantId | Format-Table -hidetableheaders | Out-String).trim()
 Write-Host "Customer",$domain,"'s Tenant ID is", $tenantid
 }


#Connect to MSOnline with or without Delegated Access
function msolconnect{
    $DelegatePermission = Read-Host -prompt "Do you require Delegated Access? (y/n)"
    if ($DelegatePermission -eq 'y'){
        Write-Host "You have prompted for Delegated Access"
        Write-Host "Enter parent credentials"
        Connect-MsolService
        Write-Host "Attempting to find tenant ID for delagted access"
        GetCustID
        GetMFA
    }
    elseif ($DelegatePermission -eq 'n'){
        Write-Host "You have prompted for Direct Access"
        Write-Host "Enter Credentials"
        Connect-Msolservice
        Get-CustomerID
        GetMFA
    }
    }

function getcustomerid{
 
    $name = $domain
    $Customers = @()
    $Customers = @(Get-MsolPartnerContract | Where-Object {$_.Name -match $name})
     
    if($Customers.Count -gt 1){
     
        Write-Host "More than 1 customer found, rerun the function:"
        Write-Host " "
     
        ForEach($Customer in $Customers){
     
            Write-Host $Customer.Name
            }
        }
     
    elseif($Customers.count -eq 0){
         
        Write-Host "No customers found, rerun the function"
        }
     
    elseif($Customers.Count -eq 1){
     
        $global:cid = $Customers.tenantid
        $tenantid = $global:cid 
        Write-Host "$($Customers.name) selected. User the -tenantid `$cid parameter to run MSOL commands for this customer."
        }
     
    }
# Get MFA Function
function GetMFA{
Write-Host "Finding Azure Active Directory Accounts..."
$Users = Get-MsolUser -tenantid $tenantid -all | Where-Object { $_.UserType -ne "Guest" }
$Report = [System.Collections.Generic.List[Object]]::new() # Create output file
Write-Host "Processing" $Users.Count "accounts..." 
ForEach ($User in $Users) {

    $MFADefaultMethod = ($User.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq "True" }).MethodType
    $MFAPhoneNumber = $User.StrongAuthenticationUserDetails.PhoneNumber
    $PrimarySMTP = $User.ProxyAddresses | Where-Object { $_ -clike "SMTP*" } | ForEach-Object { $_ -replace "SMTP:", "" }
    $Aliases = $User.ProxyAddresses | Where-Object { $_ -clike "smtp*" } | ForEach-Object { $_ -replace "smtp:", "" }

    If ($User.StrongAuthenticationRequirements) {
        $MFAState = $User.StrongAuthenticationRequirements.State
    }
    Else {
        $MFAState = 'Disabled'
    }

    If ($MFADefaultMethod) {
        Switch ($MFADefaultMethod) {
            "OneWaySMS" { $MFADefaultMethod = "Text code authentication phone" }
            "TwoWayVoiceMobile" { $MFADefaultMethod = "Call authentication phone" }
            "TwoWayVoiceOffice" { $MFADefaultMethod = "Call office phone" }
            "PhoneAppOTP" { $MFADefaultMethod = "Authenticator app or hardware token" }
            "PhoneAppNotification" { $MFADefaultMethod = "Microsoft authenticator app" }
        }
    }
    Else {
        $MFADefaultMethod = "Not enabled"
    }
  
    $ReportLine = [PSCustomObject] @{
        UserPrincipalName = $User.UserPrincipalName
        DisplayName       = $User.DisplayName
        MFAState          = $MFAState
        MFADefaultMethod  = $MFADefaultMethod
        MFAPhoneNumber    = $MFAPhoneNumber
        PrimarySMTP       = ($PrimarySMTP -join ',')
        Aliases           = ($Aliases -join ',')
    }
                 
    $Report.Add($ReportLine)
}
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host " "
Write-Host "Report is in c:\temp\MFAUsers.csv"
Write-Host " "
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

$Report | Select-Object UserPrincipalName, DisplayName, MFAState, MFADefaultMethod, MFAPhoneNumber, PrimarySMTP, Aliases | Sort-Object UserPrincipalName | Out-GridView
$Report | Sort-Object UserPrincipalName | Export-CSV -Encoding UTF8 -NoTypeInformation c:\temp\MFAUsers.csv
    }
#DelegateAccess
msolconnect
#GetMFA
Write-Host "Report is in c:\temp\MFAUsers.csv"
$Report | Select-Object UserPrincipalName, DisplayName, MFAState, MFADefaultMethod, MFAPhoneNumber, PrimarySMTP, Aliases | Sort-Object UserPrincipalName | Out-GridView
$Report | Sort-Object UserPrincipalName | Export-CSV -Encoding UTF8 -NoTypeInformation c:\temp\MFAUsers.csv