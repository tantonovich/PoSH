       
#Install Pageant to system dir
Copy-Item "\\mlpdeploy.mlpems.local\c$\software\pageant.exe" "c:\windows\system32\pageant.exe"
#Add mlpems.local to Local Intranet zone
New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\mlpems.local" 
New-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\mlpems.local" -Name "*" -Value 1 -PropertyType "DWORD"
#Remove Office 2013 click-To-Run
Remove-Item "C:\Program Files\Microsoft Office 15\root\integration\c2rmanifest*" -Force
$installer = "C:\Program Files\Microsoft Office 15\root\integration\integrator.exe"
$arguments = "/U"
Start-Process -FilePath $installer -ArgumentList $arguments -PassThru | Wait-Process

schtasks.exe /delete /tn "Microsoft\Office\Office 15 Subscription Heartbeat"
schtasks.exe /delete /tn "Microsoft\Office\Office Automatic Update"
schtasks.exe /delete /tn "Microsoft\Office\Office Subscription Maintenance"

Stop-Service -Name OfficeSvc
Stop-Process -Name appvshnotify -Force
Stop-Process -Name firstrun -Force
Stop-Process -Name setup* -Force

sc delete OfficeSvc

Remove-Item -Path "C:\Program Files\Microsoft Office 15" -Recurse -Force
Remove-Item -Path "C:\ProgramData\Microsoft\ClickToRun" -Recurse -Force
Remove-Item -Path "C:\ProgramData\Microsoft\Office\FFPackageLocker" -Force
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office 2013" -Recurse -Force

Remove-Item -Path "HKLM:\Software\Microsoft\Office\15.0\ClickToRun" -Recurse -Force
Remove-Item -Path "HKLM:\Software\Microsoft\AppVISV" -Recurse -Force
Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\ProfessionalRetail - en-us" -Recurse -Force

$installer = "msiexec.exe"
$arguments = "/X {50150000-008F-0000-1000-0000000FF1CE} /passive"
Start-Process -FilePath $installer -ArgumentList $arguments -PassThru | Wait-Process

#Install Acrobat Reader
$msifile = '\\mlpdeploy.mlpems.local\c$\software\acroreader\AdbeRdr11000_en_US.msi'
$arguments = '-passive'

Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process

#Set registry key to disable Adobe Updater and remove desktop icon
New-ItemProperty "HKLM:\Software\Policies\Adobe\Acrobat Reader\11.0\FeatureLockDown\" -Name "bUpdater" -Value 0 -PropertyType "DWORD"
Remove-Item "C:\Users\Public\Desktop\Adobe Reader XI.lnk"
#Modify the existing MS Office Installation
Write-Host "Installing Office 2013"
Set-Service -Name FontCache -StartupType Automatic
$msifile = "\\mlpdeploy.mlpems.local\c$\software\Office2013\setup.exe"
$arguments = "/adminfile \\mlpdeploy.mlpems.local\c$\software\Office2013\MLPOWKS.msp"
Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process

#Install all SCADA network printers    
Write-Host "***Installing SCADALAB-COLOR*********"
#Add the printer port
$hostAddress = "172.17.21.52" 
$portNumber = "9100"  
$computer = $env:COMPUTERNAME 

$wmi= [wmiclass]"\\$computer\root\cimv2:win32_tcpipPrinterPort" 
#$wmi.psbase.scope.options.enablePrivileges = $true 
$newPort = $wmi.createInstance() 
$newPort.hostAddress = $hostAddress 
$newPort.name = "IP_" + $hostAddress 
$newPort.portNumber = $portNumber 
$newPort.SNMPEnabled = $false 
$newPort.Protocol = 1 
$newPort.put()

#Add the Printer
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'SCADALAB-COLOR'
$printer.PortName = 'IP_172.17.21.52'
$printer.Network = $false
$printer.Shared = $false
#$printer.ShareName = 'NewPrintServer'
$printer.Location = 'Scada Lab'
$printer.DriverName = 'HP Color LaserJet CP4005 PCL6'
$printer.Put() 


Write-Host "***Installing DISPATCH-COLOR*********"
#Add the printer port
$hostAddress = "172.17.21.51" 
$portNumber = "9100"  
$computer = $env:COMPUTERNAME 

$wmi= [wmiclass]"\\$computer\root\cimv2:win32_tcpipPrinterPort" 
#$wmi.psbase.scope.options.enablePrivileges = $true 
$newPort = $wmi.createInstance() 
$newPort.hostAddress = $hostAddress 
$newPort.name = "IP_" + $hostAddress 
$newPort.portNumber = $portNumber 
$newPort.SNMPEnabled = $false 
$newPort.Protocol = 1 
$newPort.put()

#Add the Printer
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'DISPATCH-COLOR'
$printer.PortName = 'IP_172.17.21.51'
$printer.Network = $false
$printer.Shared = $false
#$printer.ShareName = 'NewPrintServer'
$printer.Location = 'Dispatch'
$printer.DriverName = 'HP Color LaserJet CP4005 PCL6'
$printer.Put() 
#To get above variables, manually install printer and run the command below:
#gwmi win32_printer | Select *

Write-Host "***Installing SCADALAB-BW*********"
#Add the printer port
$hostAddress = "172.17.21.61" 
$portNumber = "9100"  
$computer = $env:COMPUTERNAME 

$wmi= [wmiclass]"\\$computer\root\cimv2:win32_tcpipPrinterPort" 
#$wmi.psbase.scope.options.enablePrivileges = $true 
$newPort = $wmi.createInstance() 
$newPort.hostAddress = $hostAddress 
$newPort.name = "IP_" + $hostAddress 
$newPort.portNumber = $portNumber 
$newPort.SNMPEnabled = $false 
$newPort.Protocol = 1 
$newPort.put()

#Add the Printer
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'SCADALAB-BW'
$printer.PortName = 'IP_172.17.21.61'
$printer.Network = $false
$printer.Shared = $false
#$printer.ShareName = 'NewPrintServer'
$printer.Location = ''
$printer.DriverName = 'HP LaserJet P4014/P4015 PCL6'
$printer.Put() 

Write-Host "***Installing ENG-BW*********"
#Add the printer port
$hostAddress = "172.17.21.63" 
$portNumber = "9100"  
$computer = $env:COMPUTERNAME 

$wmi= [wmiclass]"\\$computer\root\cimv2:win32_tcpipPrinterPort" 
#$wmi.psbase.scope.options.enablePrivileges = $true 
$newPort = $wmi.createInstance() 
$newPort.hostAddress = $hostAddress 
$newPort.name = "IP_" + $hostAddress 
$newPort.portNumber = $portNumber 
$newPort.SNMPEnabled = $false 
$newPort.Protocol = 1 
$newPort.put()

#Add the Printer
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'ENG-BW'
$printer.PortName = 'IP_172.17.21.63'
$printer.Network = $false
$printer.Shared = $false
#$printer.ShareName = 'NewPrintServer'
$printer.Location = ''
$printer.DriverName = 'HP LaserJet P4014/P4015 PCL6'
$printer.Put() 

Write-Host "***Installing ALT-DISP-BW*********"
#Add the printer port
$hostAddress = "172.28.66.101" 
$portNumber = "9100"  
$computer = $env:COMPUTERNAME 

$wmi= [wmiclass]"\\$computer\root\cimv2:win32_tcpipPrinterPort" 
#$wmi.psbase.scope.options.enablePrivileges = $true 
$newPort = $wmi.createInstance() 
$newPort.hostAddress = $hostAddress 
$newPort.name = "IP_" + $hostAddress 
$newPort.portNumber = $portNumber 
$newPort.SNMPEnabled = $false 
$newPort.Protocol = 1 
$newPort.put()

#Add the Printer
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'ALT-DISP-BW'
$printer.PortName = 'IP_172.28.66.101'
$printer.Network = $false
$printer.Shared = $false
#$printer.ShareName = 'NewPrintServer'
$printer.Location = ''
$printer.DriverName = 'HP LaserJet P4014/P4015 PCL6'
$printer.Put() 

Write-Host "***Installing SCADAOPS-BW*********"
#Add the printer port
$hostAddress = "172.17.21.66" 
$portNumber = "9100"  
$computer = $env:COMPUTERNAME 

$wmi= [wmiclass]"\\$computer\root\cimv2:win32_tcpipPrinterPort" 
#$wmi.psbase.scope.options.enablePrivileges = $true 
$newPort = $wmi.createInstance() 
$newPort.hostAddress = $hostAddress 
$newPort.name = "IP_" + $hostAddress 
$newPort.portNumber = $portNumber 
$newPort.SNMPEnabled = $false 
$newPort.Protocol = 1 
$newPort.put()

#Add the Printer
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'SCADAOPS-BW'
$printer.PortName = 'IP_172.17.21.66'
$printer.Network = $false
$printer.Shared = $false
#$printer.ShareName = 'NewPrintServer'
$printer.Location = ''
$printer.DriverName = 'HP LaserJet P4014/P4015 PCL6'
$printer.Put() 

Write-Host "***Installing EKLUTNA-BW*********"
#Add the printer port
$hostAddress = "172.30.76.60" 
$portNumber = "9100"  
$computer = $env:COMPUTERNAME 

$wmi= [wmiclass]"\\$computer\root\cimv2:win32_tcpipPrinterPort" 
#$wmi.psbase.scope.options.enablePrivileges = $true 
$newPort = $wmi.createInstance() 
$newPort.hostAddress = $hostAddress 
$newPort.name = "IP_" + $hostAddress 
$newPort.portNumber = $portNumber 
$newPort.SNMPEnabled = $false 
$newPort.Protocol = 1 
$newPort.put()

#Add the Printer
$printerclass = [wmiclass]'Win32_Printer'
$printer = $printerclass.CreateInstance()
$printer.Name = $printer.DeviceID = 'EKLUTNA-BW'
$printer.PortName = 'IP_172.30.76.60'
$printer.Network = $false
$printer.Shared = $false
#$printer.ShareName = 'NewPrintServer'
$printer.Location = ''
$printer.DriverName = 'HP LaserJet P4014/P4015 PCL6'
$printer.Put() 

#Deploy custom ODBC settings
#regedit /s "\\mlpdeploy.mlpems.local\c$\software\ODBC\MLP_ODBC.reg"
#Remove-Item "C:\windows\odbc.ini"
#Copy-Item "\\mlpdeploy.mlpems.local\c$\software\odbc\odbc.ini" "C:\Windows\ODBC.ini"

#Add OSI and ORACLE_HOME environment variables
[Environment]::SetEnvironmentVariable("Path","%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\;C:\Program Files (x86)\ATI Technologies\ATI.ACE\Core-Static;C:\Program Files (x86)\NTP\bin;c:\Program Files (x86)\Java\jre7\bin;d:\monarchNET\javabin\jre\bin;C:\Program Files (x86)\openhrs\bin\hrs;E:\app\mlp_adm\product\11.2.0\client_1\bin","Machine")

#Deploy CA ArcServe Agent
Write-Host "Installing CA ArcServe Agent"
$msifile = '\\mlpdeploy.mlpems.local\c$\software\ArcServe_16.5\Install\MasterSetup.exe'
$arguments = '/I:"\\mlpdeploy.mlpems.local\c$\software\ArcServe_16.5\Setup.icf"'

Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process
    
#Deploy SnagIt Enterprise
Write-Host "Installing Snagit"
$msifile = 'msiexec.exe'
$arguments = '/i \\mlpdeploy.mlpems.local\c$\software\snagit\snagit.msi TRANSFORMS="snagit_mlp.mst" /qn'

Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process
    
#Deploy Moxa Drivers
Write-Host "Installing Moxa Drivers"
$msifile = '\\mlpdeploy.mlpems.local\c$\software\Moxa_DrvMgr\drvmgr.exe'
$arguments = '/silent'

Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process
    
#Copy Monarch Directories to workstations
Write-Host "Copying Monarch directories (this will take approx. 5 minutes)"
Copy-Item "\\mlpdeploy.mlpems.local\c$\software\monarch_dirs\monarchNET" "D:\" -Recurse -Force
Copy-Item "\\mlpdeploy.mlpems.local\c$\software\monarch_dirs\monarchNET32" "D:\" -Recurse -Force
Copy-Item "\\mlpdeploy.mlpems.local\c$\software\monarch_dirs\brick34\osi" "D:\" -Recurse -Force
#Deploy JRE for MonarchNET
$msifile = '\\mlpdeploy.mlpems.local\c$\software\jre-7-win32.exe'
$arguments = '/s'

Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process
    
#Deploy OSI ODBC 
Write-Host "Installing OSI ODBC components"
$msifile = 'D:\monarchNET32\products\OSIDDE_v2.0.3p04.exe'
$arguments = '/silent'

Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process

$msifile = 'D:\monarchNET32\products\OSIODBC_v3.1.5.6.exe'
$arguments = '/silent'

Start-Process `
    -File $msifile `
    -arg $arguments `
    -passthru | Wait-Process

$msifile = 'D:\monarchNET32\products\HRSODBC_v3.5.1p12_32.exe'
$arguments = ''

Start-Process `
    -File $msifile `
    -passthru | Wait-Process
    
\\mlpsys1\ofcscan\autopcc.exe
