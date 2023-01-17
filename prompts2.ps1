# Patrick Woodward 004278348
# Variables
# Total Memory - Free Memory = Memory Used

$WMIObject =  Get-WmiObject -Class WIN32_OperatingSystem
$UsageRAM = (($WMIObject.TotalVisibleMemorySize - $WMIObject.FreePhysicalMemory)/1024/1024)
# CPU Usage with only the numbers from the table

$CPUUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
# Get Date

$Date = Get-Date -format MM/dd/yyyy
# Write Date

$Date | Out-File C:\Requirements1\DailyLog.txt -append
#Check C:\Requirements1 for .log files and pipe them to DailyLog.txt

Get-ChildItem -Path C:\Requirements1\* -Include *.log | Format-Table -Auto -Property Name | Out-File C:\Requirements1\DailyLog.txt -Append

#List all file names in C:\Requirements1
Get-ChildItem -Path C:\Requirements1 | Sort-Object Name | Format-Table -Property Name | Out-File C:\Requirements1\C916contents.txt

# Show Current Memory and Processor Usage
echo "Current Memory Used"
Write-Host $UsageRAM" GB"

# Show Current CPU Usage
echo "Current Processor Usage"
Write-Host $CPUUsage" %"

# List all current processes
Get-Process