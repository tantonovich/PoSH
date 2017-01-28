#This script is run FROM THE SERVER and will copy and run a script
#on a remote PC. The list must be line-delimited to work.  Ex
#COMPUTER1
#COMPUTER2
#COMPUTER3

#Pull list of PC's from a .txt file
$list = Get-Content -Path .\PCList.txt
#Runs the action on each PC
foreach ($i in $list) {
    $pc = $i
    Write-Host Running Script for $pc
    $connectionTest = Test-Connection -ComputerName $pc -quiet
    if($connectionTest) {
    #Check to see if the program's directory exists
    $pathExist = Test-Path "\\$pc\c$\Program Files (x86)\Adobe\Adobe Creative Cloud"
    if ($pathExist -eq $false) {
    #Copy a separate installer script and install filesto the target, then run it locally.
    #This is necessary due to the way MSI and Windows Installer functions.
   	New-PSDrive -Name Installer -PSProvider FileSystem -root \\agsrwd02.corp.agdc.us\d$\Adobe\adobepro\Build
	New-Item \\$pc\c$\Adobe_temp -Type Directory
	Copy-Item Installer:\ \\$pc\c$\Adobe_temp -Recurse
	Copy-Item ".\Install_AdobeApps.ps1" \\$pc\c$\
    Invoke-Command -ComputerName $pc -ScriptBlock{powershell -file c:\Install_AdobeApps.ps1}
    Remove-Item \\$pc\c$\Install_AdobeApps.ps1
    Write-Host Script has been executed on $pc
    Write-Host 
        }
      else {write-host Application appears to be installed
      Write-Host }
            }
        else {Write-Host $pc Is Offline}
    
      }
