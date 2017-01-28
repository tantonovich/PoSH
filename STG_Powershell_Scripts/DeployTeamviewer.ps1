#This script is run FROM THE SERVER and will pull a list of computers
#from AD, check if the PC is online, then install if it is online.  Pay
#attention to the path to the 'InstallTeamviewer.ps1' location.  This 
#script will copy that file to the remote PC and run it for install.

Import-Module ActiveDirectory
#Modify the LDAP path to the OU where the domain computers are located.
$list = Get-ADComputer -filter * -SearchBase "OU=STG Computers,DC=stg,DC=local"
#Run the script on all PC's that are online
foreach ($computer in $list) {
    $pc = $computer.name
    Write-Host "Running Script for" $pc
    $connectionTest = Test-Connection -ComputerName $pc -quiet
    if ($connectionTest) {
    #Modify the path below to the local directory on the server containing the PS script for the remote client install
    Copy-Item D:\IT\Powershell_Scripts\InstallTeamviewer.ps1 \\$pc\c$\
    Invoke-Command -ComputerName $pc -ScriptBlock{powershell -file c:\tv_install.ps1}
    Remove-Item \\$pc\c$\tv_install.ps1
    Write-Host "Script has been executed on" $pc
    Write-Host "********************************"
      		 }
      else {write-host "Client is Offline"
      Write-Host "********************************"}
    
      }
