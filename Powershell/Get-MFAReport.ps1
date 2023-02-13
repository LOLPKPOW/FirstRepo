# Comment to remember Remote Execution Policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Choose report download directory and file name 


# Function to find Tenant ID
function GetCustID{
 $global:domain = Read-Host -prompt "Type the domain name"
 $global:tenantid = (Get-MsolPartnerContract -DomainName $domain | Select-Object TenantId | Format-Table -hidetableheaders | Out-String).trim()
 Write-Host "Customer",$domain,"'s Tenant ID is", $tenantid
 }


# Connect to MSOnline with or without Delegated Access
function msolconnect{
    $DelegatePermission = Read-Host -prompt "Do you require Delegated Access? (y/n)"
    if ($DelegatePermission -eq 'y'){
        $reportdir = Read-Host -prompt "Specify full path for directory to save file (i.e. 'C:\Windows\Temp\)"
        $reportname = Read-Host -prompt "Specify file name without extension (i.e. MFAReport)"
        $reportfile = $reportdir + $reportname + '.csv'
        Write-Host "You have prompted for Delegated Access"
        Write-Host "Enter parent credentials"
        Connect-MsolService
        Write-Host "Attempting to find tenant ID for delagted access"
        GetCustID
        GetMFA
        WriteReport
        DoItAgain
    }
    elseif ($DelegatePermission -eq 'n'){
        $reportdir = Read-Host -prompt "Specify full path for directory to save file (i.e. 'C:\Windows\Temp\)"
        $reportname = Read-Host -prompt "Specify file name without extension (i.e. MFAReport)"
        $reportfile = $reportdir + $reportname + '.csv'
        Write-Host "You have prompted for Direct Access"
        Write-Host "Enter Credentials"
        Connect-Msolservice
        GetMFA
        WriteReport
        DoItAgain
    }
    }
# Get MFA Function
function GetMFA{
Write-Host "Finding Azure Active Directory Accounts..."
$global:Users = Get-MsolUser -tenantid $tenantid -all | Where-Object { $_.UserType -ne "Guest" }
$global:Report = [System.Collections.Generic.List[Object]]::new() # Create output file
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
# Report writing function
function WriteReport{
    $Report | Select-Object UserPrincipalName, DisplayName, MFAState, MFADefaultMethod, MFAPhoneNumber, PrimarySMTP, Aliases | Sort-Object UserPrincipalName | Out-GridView

    $Report | Sort-Object UserPrincipalName | Export-CSV -Encoding UTF8 -NoTypeInformation $reportfile

    Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    Write-Host " "
    Write-Host "Report is in", $reportdir
    Write-Host " "
    Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
}
    }
function DoItAgain{
    $AnotherRound = Read-Host -prompt "Would you like to make another report? (y/n)"
    if ($AnotherRound -eq "y"){
        $DelegatePermission2 = Read-Host -prompt "Is this for another delegate permission required client? (y/n)"
        if ($DelegatePermission2 -eq "y"){
            if ($tenantid -ne $null){
            Connect-MsolService
            Write-Host "Attempting to find tenant ID for delagted access"
            GetCustID
            GetMFA
            WriteReport
        }
            elseif ($tenantid -eq $null){
                msolconnect
            }
    }
        elseif ($DelegatePermission2 -eq "n"){
            msolconnect
        }
        else{
            Write-Host "Invalid Entry. Try again."
            DoItAgain
        } 
    }
    elseif ($AnotherRound -eq "n"){
        Write-Host "Thanks for using my MFA audit script"
    }
    else{
        Write-Host "Invalid Entry"
        DoItAgain
    }
    }
msolconnect
