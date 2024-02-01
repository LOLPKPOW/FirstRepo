#
# Script for Common PowerShell-Only O365 Features
# Log In 
# Patrick Woodward
function loginfunc{
Import-Module ExchangeOnlineManagement
Write-Host 'This script was written to assist in common PowerShell only Exchange-Online features.'
$DelegatePermission = Read-Host -Prompt 'Do you need to access Exchange Online with delegated access? (y/n)'
Write-Host 'After inputting credentials you will be presented options for features'
exchangeconnect
}

# Delegated Access Function
function delegateaccess{
    Write-Host 'You have prompted for Delegated Access'
    $DelegDomain = Read-Host -prompt 'Enter domain you need to connect to'
    Connect-ExchangeOnline -DelegatedOrganization $DelegDomain
    }
# Direct Access Function
function regaccess{
    Write-Host 'You have prompted for Direct Access'
    Connect-ExchangeOnline
    }

# Connect Function
function exchangeconnect{
    if ($DelegatePermission -eq 'y'){
        Write-Host 
        delegateaccess
        }
    elseif ($DelegatePermission -eq 'n'){
        regaccess
        }
        }

# Shared Calendar Function (and send notification upon completed sharing)
function SharedCalendarFunc {
        $CalendarToShare = Read-Host -Prompt 'Enter the e-mail of the user who has the calendar you want to share'
        $CalendarToShare = $CalendarToShare + ':\Calendar'
        $CalendarSharedTo = Read-Host -Prompt 'Enter the e-mail of the user who needs access to the calendar'
        $CalendarPermission = Read-Host -Prompt 'Enter 1 for Read-Only, and 2 for Read-Write'
        if ($CalendarPermission -eq 1){
            $CalendarPermission = 'Reviewer'
            }
        elseif ($CalendarPermission -eq 2){
            $CalendarPermission = 'Editor'
            }
        Add-MailboxFolderPermission -Identity $CalendarToShare -User $CalendarSharedTo -AccessRights $CalendarPermission -SendNotificationToUser $true
        Write-Host 'Notification Sent of Permission Granted'
        }

# Remove Calendar Permissions
function RemoveCalendarFunc {
        $CalendarToShare = Read-Host -Prompt 'Enter the e-mail of the user who has the calendar you want to remove permissions from'
        $CalendarToShare = $CalendarToShare + ':\Calendar'
        $CalendarSharedTo = Read-Host -Prompt 'Enter the e-mail of the user who needs permissions removed'
        Remove-MailboxFolderPermission -Identity $CalendarToShare -User $CalendarSharedTo
        Write-Host $CalendarSharedTo, 'has had permissions removed from the calendar of', $CalendarToShare
        }
# Modify Calendar Permissions
function ModifyCalendarFunc {
        $CalendarToShare = Read-Host -Prompt 'Enter the e-mail of the user who has the calendar you want to share'
        $CalendarToShare = $CalendarToShare + ':\Calendar'
        $CalendarSharedTo = Read-Host -Prompt 'Enter the e-mail of the user who needs access to the calendar'
        $CalendarPermission = Read-Host -Prompt 'Enter 1 for Read-Only, and 2 for Read-Write'
        if ($CalendarPermission -eq 1){
            $CalendarPermission = 'Reviewer'
            }
        elseif ($CalendarPermission -eq 2){
            $CalendarPermission = 'Editor'
            }
        Set-MailboxFolderPermission -Identity $CalendarToShare -User $CalendarSharedTo -AccessRights $CalendarPermission -SendNotificationToUser $true
        Write-Host 'Permissions Modified'
        Write-Output $CalendarSharedTo, "has", $CalendarPermission, "to", "$CalendarToShare", "Calendar"
        Write-Output $CalendarPermission
        Write-Output $CalendarToShare
        }

# Shared Contacts Function (and send notification upon completed sharing)
function SharedContactsFunc {
    $ContactsToShare = Read-Host -Prompt 'Enter the e-mail of the user who has the contacts you want to share'
    $ContactsToShare = $ContactsToShare + ':\Contacts'
    $ContactsSharedTo = Read-Host -Prompt 'Enter the e-mail of the user who needs access to the contacts'
    $ContactsPermission = Read-Host -Prompt 'Enter 1 for Read-Only, and 2 for Read-Write'
    
    if ($ContactsPermission -eq 1) {
        $ContactsPermission = 'Reviewer'
    }
    elseif ($ContactsPermission -eq 2) {
        $ContactsPermission = 'PublishingEditor'
    }
    
    Add-MailboxFolderPermission -Identity $ContactsToShare -User $ContactsSharedTo -AccessRights $ContactsPermission -SendNotificationToUser $true
    Write-Host 'Notification Sent of Permission Granted'
}

# Remove Contacts Permissions
function RemoveContactsFunc {
    $ContactsToShare = Read-Host -Prompt 'Enter the e-mail of the user who has the contacts you want to remove permissions from'
    $ContactsToShare = $ContactsToShare + ':\Contacts'
    $ContactsSharedTo = Read-Host -Prompt 'Enter the e-mail of the user who needs permissions removed'
    Remove-MailboxFolderPermission -Identity $ContactsToShare -User $ContactsSharedTo
    Write-Host $ContactsSharedTo, 'has had permissions removed from the contacts of', $ContactsToShare
}

# Modify Contacts Permissions
function ModifyContactsFunc {
    $ContactsToShare = Read-Host -Prompt 'Enter the e-mail of the user who has the contacts you want to share'
    $ContactsToShare = $ContactsToShare + ':\Contacts'
    $ContactsSharedTo = Read-Host -Prompt 'Enter the e-mail of the user who needs access to the contacts'
    $ContactsPermission = Read-Host -Prompt 'Enter 1 for Read-Only, and 2 for Read-Write'
    
    if ($ContactsPermission -eq 1) {
        $ContactsPermission = 'Reviewer'
    }
    elseif ($ContactsPermission -eq 2) {
        $ContactsPermission = 'PublishingEditor'
    }
    
    Set-MailboxFolderPermission -Identity $ContactsToShare -User $ContactsSharedTo -AccessRights $ContactsPermission -SendNotificationToUser $true
    Write-Host 'Permissions Modified'
    Write-Output $ContactsSharedTo, "has", $ContactsPermission, "to", "$ContactsToShare", "Contacts"
    Write-Output $ContactsPermission
    Write-Output $ContactsToShare
}


# Force Retention Policy Function
function ForceRetentionPolicyFunc {
        $MailboxForPolicyForce = Read-Host -Prompt 'Enter email of the mailbox to force the retention policy'
        Start-ManagedFolderAssistant -Identity $MailboxForPolicyForce
	    Write-Host 'Force Retention Policy Complete'
        }


# Check Inbox Rules Function
function InboxRulesFunc {
        $MailboxForInboxRules = Read-Host -Prompt 'Enter email of the mailbox to check for inbox rules'
        Get-InboxRule -Mailbox $MailboxForInboxRules
        }

# Find Inactive Users Function
function MailboxLastLoginFunc {
	Get-EXOMailbox -ResultSize Unlimited | ForEach-Object {Get-MailboxStatistics -Identity $_.UserPrincipalName | Select-Object DisplayName, LastLogonTime} | Sort-Object LastLogonTime | Format-Table DisplayName, LastLogonTime -Auto
	}

# Set Autoreply for user
function SetAutoReply {
    $AutoReplyBox = Read-Host -Prompt 'Enter the email of the user to set auto reply for.'
    $StartDate = Read-Host -Prompt 'Enter Start Date (XX/XX/XXXX)'
    $StartTime = Read-Host -Prompt 'Enter Start Time (XX:XX:XX)'
    $ReplyBegins = '"' + $StartDate + ' ' + $StartTime + '"'
    $EndDate = Read-Host -Prompt 'Enter End Date (XX/XX/XXXX)'
    $EndTime = Read-Host -Prompt 'Enter End Time (XX:XX:XX)'
    $ReplyEnds = '"' + $EndDate + ' ' + $EndTime + '"'
    $InternalMessage = Read-Host -Prompt 'Enter internally distributed OOO message'
    $InternalMessage = '"' + $InternalMessage + '"'
    $ExternalMessage = Read-Host -Prompt 'Enter externally distributed OOO message'
    $ExternalMessage = '"' + $ExternalMessage + '"'
    Set-MailboxAutoReplyConfiguration -Identity $AutoReplyBox -AutoReplyState Scheduled -StartTime $ReplyBegins -EndTime $ReplyEnds -InternalMessage $InternalMessage -ExternalMessage $ExternalMessage
    }

# Export all groups and their members
function ExportGroups {
# Select file path to save the file
    $ExportGroupsPath = Read-Host -prompt "Enter path to save the file, including the trailing '\'"
    #Select file name for the file, without the .csv
    $ExportGroupsFileName = Read-Host -prompt "Enter the file name to save the report as (don't include .csv)"
# Get all groups (both distribution and 365 groups)
    $groups = Get-UnifiedGroup -ResultSize Unlimited

    # Create an empty array to store group information
    $groupInfo = @()

    foreach ($group in $groups) {
        $groupMembers = Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members
        $members = $groupMembers | Select-Object DisplayName, PrimarySmtpAddress    
        $groupInfo += [PSCustomObject]@{
            "GroupName" = $group.DisplayName
            "Members" = $members.DisplayName -join ", "
            "Emails" = $members.PrimarySmtpAddress -join ", "
            "Owners" = ($group | Select-Object -ExpandProperty ManagedBy) -join ", "
        }
    }

# Export the data to a CSV file
$groupInfo | Export-Csv -Path ($ExportGroupsPath + $ExportGroupsFileName + ".csv") -NoTypeInformation
}

# Set Week Start Day
function SetWeekStartDayFunc {
    $SetWeekUser = Read-Host -prompt "Enter email of user to set start day of the week"
    $SetDayOfWeek = Read-Host -prompt "Enter day of week (i.e. Monday, Tuesday etc)"
    Set-MailboxCalendarConfiguration -Identity $SetWeekUser -WeekStartDay $SetDayOfWeek
    }

# Make Selection Function
function MakeSelectionFunc {
Write-Host 'Calendar Share: Press 1'
Write-Host 'Force Retention Policy: Press 2'
Write-Host 'Check Inbox Rules: Press 3'
Write-Host 'Check Last Login All Mailboxes in Org: Press 4 (This may take a couple of minutes)'
Write-Host 'Modify existing Calendar Share Permissions: Press 5'
Write-Host 'Set Auto Reply schedule for specific mailbox: Press 6'
Write-Host 'Remove Calendar Permissions: Press 7'
Write-Host 'Export Groups and Membership List: Press 8'
Write-Host 'Set WeekStartDay per mailbox: Press 9'
Write-Host 'Contact Share: Press 10'
Write-Host 'Remove Contacts Permissions: Press 11'
Write-Host 'Modify Contact Sharing Permissions: Press 12'

$selection = Read-Host -Prompt 'Enter Selection'
if ($selection -eq 1){
    SharedCalendarFunc | Out-Host
    RepeatFunc
    }
elseif ($selection -eq 2){
    ForceRetentionPolicyFunc | Out-Host
    RepeatFunc
    }
elseif ($selection -eq 3){
    InboxRulesFunc | Out-Host
    RepeatFunc
    }
elseif ($selection -eq 4){
    MailboxLastLoginFunc | Out-Host
    RepeatFunc
    }
elseif ($selection -eq 5){
    ModifyCalendarFunc | Out-Host
    RepeatFunc
    }
elseif ($selection -eq 6){
    SetAutoReply | Out-Host
    RepeatFunc
    }
elseif ($selection -eq 7){
    RemoveCalendarFunc | Out-Host
    RepeatFunc
}
elseif ($selection -eq 8){
    ExportGroups | Out-Host
    RepeatFunc
    }
elseif ($Selection -eq 9){
    SetWeekStartDayFunc | Out-Host
    RepeatFunc
    }
elseif ($Selection -eq 10){
    SharedContactsFunc | Out-Host
    RepeatFunc
    }
elseif ($Selection -eq 11){
    RemoveContactsFunc | Out-Host
    RepeatFunc
    }
elseif ($Selection -eq 12){
    ModifyContactsFunc | Out-Host
    RepeatFunc
else{
    Write-Host '~~~~~~~~~~~~~~~~~'
    Write-Host 'Invalid Selection'
    Write-Host '~~~~~~~~~~~~~~~~~'
    MakeSelectionFunc
    }}
    

# Repeat Function
function repeatfunc {
    $repeat = Read-Host 'Would you like to make another selection? Y/N'
    if ($repeat -eq 'Y'){
        MakeSelectionFunc
        }
    else {Write-Host 'Thanks for using my script'
        Write-Host 'Closing the prompt now...'
        Disconnect-ExchangeOnline -Confirm:$false
        }
        }

# Run the script
    loginfunc
    MakeSelectionFunc
