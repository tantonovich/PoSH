#Script will create new AD accounts and populate AD attributes from CSV,
#then will add an Exchange Mailbox.  This script also sorts the users into the
#correct AD OU based on the "Group" column in the AGDC_Users.csv

#Load the Exchange and AD commands
$RemoteEx2013Session = New-PSSession -ConfigurationName Microsoft.Exchange `
                                     -ConnectionUri http://agsrex01.corp.agdc.us/PowerShell/ `
                                     -Authentication Kerberos #-Credential (Get-credential)
Import-PSSession $RemoteEx2013Session
Import-Module ActiveDirectory

$LogTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
#  Log file name:
$LogFile = 'C:\'+"Add-ADUsers-Log_"+$LogTime+".txt"
Start-Transcript -Path $LogFile
Import-Csv c:\Users\tantonovich.AGDC\Documents\AD_Deltas.csv | foreach {
#Logic for OU sorting
    $groupname = $_.Group
    switch -regex ($groupname) {
        'AGDC' { $adpath = "OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        'ASAP' { $adpath = "OU=ASAP Contract,OU=Contracts,OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        'RDI' { $adpath = "OU=RDI,OU=Vendors,OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        'NBS'  { $adpath = "OU=NBS,OU=Vendors,OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        'GCI' { $adpath = "OU=GCI,OU=Vendors,OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        'CTG' { $adpath = "OU=CTG,OU=Vendors,OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        'CH2MHILL' { $adpath = "OU=CH2MHill,OU=ASAP Contract,OU=Contracts,OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        default { $adpath = "OU=AGDC CORP Users,DC=corp,DC=agdc,DC=us" }
        }
     switch -regex ($groupname) {
        'AGDC' { $upn = "@agdc.us" }
        'ASAP' { $upn = "@asap.agdc.us" }
        'RDI' { $upn = "@contractor.agdc.us" }
        'NBS'  { $upn = "@contractor.agdc.us" }
        'GCI' { $upn = "@contractor.agdc.us" }
        'CTG' { $upn = "@contractor.agdc.us" }
        'CH2MHILL' { $upn = "@contractor.agdc.us" }
        default { $upn = "@agdc.us" }
        }
#Test if user account already exists
    $user = $(try {Get-ADUser -Identity $_.SamAccountName} catch {$null})
    If($user -eq $null)
    {
#Create the account and mailbox
    $pw = $_.Password
    New-ADUser -Name ($_.GivenName + " " + $_.sn) -GivenName $_.GivenName -Surname $_.sn -DisplayName $_.DisplayName -Description $_.Description -Office $_.Office -OfficePhone $_.TelephoneNumber -MobilePhone $_.mobile -StreetAddress $_.Street -City $_.City -State $_.State -PostalCode $_.PostalCode -Country $_.Country -Title $_.Title -Department $_.Department -Company $_.Company -UserPrincipalName ($_.SamAccountName + $upn) -SamAccountName $_.SamAccountName -ScriptPath 'agdc-default-logon.bat' -AccountPassword (ConvertTo-SecureString -String $pw  -AsPlainText -force) -ChangePasswordAtLogon $true -Path $adpath -Enabled $true
    Start-Sleep -s 5
    Enable-Mailbox -Identity $_.SamAccountName
    Write-Host  ("USER " + $_.SamAccountName + " CREATED SUCCESSFULLY")
    }
    Else {
       ("USER " + $_.SamAccountName + " ALREADY EXISTS") }
     } 
Stop-Transcript
