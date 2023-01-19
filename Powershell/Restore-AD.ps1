# Patrick Woodward 004278348

# Script to check if Finance OU is created. If exists, delete and remake. Output OU deleted. If not to create it.
# import financePersonel.csv, generate an output named AdResults.txt
# import First Name, Last Name, Display Name (1st + Last), Postal Code, Office Phone, Mobile Phone

# Variables for code clarity

$Path = 'OU=Finance,DC=PWoodward,DC=info'
$CheckFinance = ([adsi]::Exists('LDAP://' + $Path))

# If Finance OU exists, remove accidental deletion, delete, and re-add
if($CheckFinance){Write-Host "Finance OU already exists"
    Set-ADOrganizationalUnit -Identity "OU=Finance,DC=PWoodward,DC=info" -ProtectedFromAccidentalDeletion $false
    Remove-ADOrganizationalUnit -Identity "OU=Finance,DC=PWoodward,DC=info"
    New-ADOrganizationalUnit Finance
    Write-Host "Finance OU recreated"}
# If Finance OU doesn't exist, make it
else{Write-Host "Finance OU doesn't exist. Creating now..."
    New-AdOrganizationalUnit Finance}

# Import financePersonnel.csv
$CSVFile = "C:\Users\Patrick\Desktop\financePersonnel.csv"
Import-Csv $CSVFile | ForEach-Object {
# Begin Writing each user
    Write-Host "Creating user" $_.First_Name $_.Last_Name
# Concatenate First and Last to be Display Name
    $DisplayName = "$($_.First_Name) $($_.Last_Name)"
# Add each user using specific columns from CSV
    New-ADUser -path $Path -GivenName $_.First_Name -Surname $_.Last_Name -Name $DisplayName -DisplayName $DisplayName `
    -SamAccountName $_.samAccount -City $_.City -PostalCode $_.PostalCode -OfficePhone $_.OfficePhone -MobilePhone $_.MobilePhone
    
    }
# Create output file with all added users 
Get-ADUser -Filter * -SearchBase “ou=Finance,dc=PWoodward,dc=info” -Properties DisplayName,PostalCode,OfficePhone,MobilePhone > .\AdResults.txt