# Script for Common PowerShell-Only O365 Features
# Log In
# Patrick W.
function loginfunc{
Import-Module ExchangeOnlineManagement
Write-Host 'This script was written to assist in common PowerShell only Exchange-Online features.'
Write-Host 'After inputting credentials you will be presented options for features'
Connect-ExchangeOnline
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
	Get-EXOMailbox -ResultSize Unlimited | ForEach-Object {Get-MailboxStatistics -Identity $_.UserPrincipalName | Select DisplayName, LastLogonTime} | Sort-Object LastLogonTime | Format-Table DisplayName, LastLogonTime -Auto
	}

# Make Selection Function
function MakeSelectionFunc {
Write-Host 'Calendar Share: Press 1'
Write-Host 'Force Retention Policy: Press 2'
Write-Host 'Check Inbox Rules: Press 3'
Write-Host 'Check Last Login All Mailboxes in Org: Press 4 (This may take a couple of minutes)'
Write-Host 'Modify existing Calendar Share Permissions: Press 5'

$selection = Read-Host -Prompt 'Enter Selection'
if ($selection -eq 1){
    SharedCalendarFunc | Out-Host
    }
elseif ($selection -eq 2){
    ForceRetentionPolicyFunc | Out-Host
    }
elseif ($selection -eq 3){
    InboxRulesFunc | Out-Host
    }
elseif ($selection -eq 4){
    MailboxLastLoginFunc | Out-Host
    }
elseif ($selection -eq 5){
    ModifyCalendarFunc | Out-Host
    RepeatFunc
    }
    }


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

    loginfunc
    MakeSelectionFunc
