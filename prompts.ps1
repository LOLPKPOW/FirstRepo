# Patrick Woodward 004278348
# Variables
# Total Memory - Free Memory = Memory Used
$Variable = 1
$WMIObject =  Get-WmiObject -Class WIN32_OperatingSystem
$UsageRAM = (($WMIObject.TotalVisibleMemorySize - $WMIObject.FreePhysicalMemory)/1024/1024)
# CPU Usage with only the numbers from the table

$CPUUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
# Get Date
$Date = Get-Date -format MM/dd/yyyy 
# Get Data to write to Datalog.txt
# $LogFiles = {Get-ChildItem -Path C:\Requirements1\* -Include *.log | Format-Table -Auto -Property Name}
# Date + Log Files
# $DateLog = $Date + $LogFiles

# While entered number is less than or equal to 5 and greater than or equal to 1
while($Variable -le 5 -and $Variable -ge 1)
 {
# Asking user for input
 echo "Please enter 1 for a list of log files in Requirements1 exported to DailyLog.txt."
 echo "Please enter 2 for a list of files in Requirements1 exported to C916contents.txt."
 echo "Please enter 3 for current CPU Usage and Memory Usage."
 echo "Please enter 4 for all the running processes."
 echo "Please enter 5 to quit."
# Command to take user input
 $Variable = Read-Host
# Begin checking which number was input and taking specific action
try
{
 if($Variable -eq 1){$Date | Format-Table -Auto -Property Name | Out-File C:\Requirements1\DailyLog.txt -Append
    Get-ChildItem -Path C:\Requirements1\* -Include *.log | Format-Table -Auto -Property Name | Format-Table -Auto -Property Name | Out-File C:\Requirements1\DailyLog.txt -Append}
 elseif ($Variable -eq 2){Get-ChildItem -Path C:\Requirements1 | Sort-Object Name | Format-Table -Property Name | Out-File C:\Requirements1\C916contents.txt}
 elseif ($Variable -eq 3){echo "Current Memory Used" Write-Host $UsageRAM" GB" echo "Current Processor Usage" Write-Host $CPUUsage" %"}
 elseif ($Variable -eq 4){Get-Process | Sort vm | select name, vm | Out-GridView -Title "Processes Sorted by Virtual Memory Utilization"}
 elseif ($Variable -eq 5){Break}
 else {"Invalid Entry. Try again."}
  $Variable = 1
 }
 catch [System.OutOfMemoryException]
{
  echo "Error. System.OutOfMemoryException"
   Break
   }}