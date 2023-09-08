# Unsigned Scripts
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# Instructions
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host "This will extract .xlsx, .doc, .docx, and .pdf files to a folder"
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

# Set the mailbox and folder name
$mailboxName = Read-Host -prompt "Enter name of Mailbox you want to extract from"
$folderName = "Inbox"

# Create an instance of Outlook Application
$outlook = New-Object -ComObject Outlook.Application

# Get the specific mailbox
$mailbox = $outlook.Session.Folders | Where-Object { $_.Name -eq $mailboxName }

# Get the specific folder within the mailbox
$folder = $mailbox.Folders | Where-Object { $_.Name -eq $folderName }

# Prompt where to write the file
$dir = "C:\temp\pwoodward"

# Function to pull and write specific file extensions
$filepath = $dir
$folder.Items | foreach {
    $SendName = $_.SenderName
    $_.Attachments | foreach {
        Write-Host $_.filename
        $a = $_.filename
        $name = $a
        If ($a.Contains("xlsx")) {
            $_.saveasfile((Join-Path $filepath "$name"))
        }
        ElseIf ($a.Contains("doc")) {
            $_.saveasfile((Join-Path $filepath "$name"))
        }
        ElseIf ($a.Contains("docx")) {
            $_.saveasfile((Join-Path $filepath "$name"))
        }
        ElseIf ($a.Contains("pdf")) {
            $_.saveasfile((Join-Path $filepath "$name"))
        }
    }
}