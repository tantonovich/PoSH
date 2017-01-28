Import-Module ActiveDirectory
#Pull list of PC's from AD
$list = Get-ADComputer -filter * -SearchBase "OU=OrgUnit,DC=subdomain,DC=domain,DC=local"
#Runs the action on each PC
foreach ($computer in $list) {
    $pc = $computer.name
    #Add commands here, examples below are to run an installer script on each PC
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
