#This script is run FROM THE SERVER and will pull a list of computers
#from AD, check if the PC is online, check if it already has Communicator, 
#then install if it is online.  Pay
#attention to the path to the 'InstallCommunicator.ps1' location.  This 
#script will copy that file to the remote PC and run it for install.

Import-Module ActiveDirectory
#Pull list of PC's from AD
$list = Get-ADComputer -filter * -SearchBase "OU=STG Computers,DC=stg,DC=local"
#Runs the action on each PC
foreach ($computer in $list) {
    $pc = $computer.name
    Write-Host "Running Script for" $pc
    $connectionTest = Test-Connection -ComputerName $pc -quiet
    if($connectionTest) {
    $pathExist = Test-Path "\\$pc\c$\Program Files (x86)\Shoreline Communications"
    if ($pathExist) {
    Copy-Item d:\it\Powershell_Scripts\Install_Communicator.ps1 \\$pc\c$\
    Invoke-Command -ComputerName $pc -ScriptBlock{powershell -file c:\Install_Communicator.ps1}
    Remove-Item \\$pc\c$\Install_Communicator.ps1
    Write-Host "Script has been executed on" $pc
    Write-Host "********************************"
        }
      else {write-host "No Communicator Client Installed!"
      Write-Host "********************************"}
            }
        else {Write-Host $pc "Is Offline"}
    
      }