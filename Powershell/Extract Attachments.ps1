
# Unsigned Scripts
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# Instructions
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Write-Host "This will extract .xlsx, .doc, .docx, and .pdf files to folder of your choice"
Write-Host "Outlook will open and prompt to choose a folder"
Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
# Prompt where to write the file
$dir = Read-Host -prompt "Enter destination folder name to create file (make sure directory exists!)"
# Where to pull the file from and which folder in Outlook
$o = New-Object -comobject outlook.application
$n = $o.GetNamespace("MAPI")
$f = $n.PickFolder()
# Function to pull and write specific file extensions
$filepath = $dir
$f.Items| foreach {
 $SendName = $_.SenderName
   $_.attachments|foreach {
    Write-Host $_.filename
    $a = $_.filename
    $name = $a
    If ($a.Contains("xlsx")) {
    $_.saveasfile((Join-Path $filepath "$name"))
   }
    Elseif ($a.Contains("doc")) {
    $_.saveasfile((Join-Path $filepath "$name"))
    }
    Elseif ($a.Contains("docx")) {
    $_.saveasfile((Join-Path $filepath "$name"))
    }
    Elseif ($a.Contains("pdf")) {
    $_.saveasfile((Join-Path $filepath "$name"))
    }
  }
}
# Change to chosen folder
cd $dir
# Export
Dir | Export-CSV $dir\Attachments.CSV