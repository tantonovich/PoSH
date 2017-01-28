#DON'T FORGET TO ENTER DOMAIN CREDENTIALS
#Map drive for Powershell to use on remote PC
Net use z: \\server3\stgdata /user:domain\username password
#Create temp directory on remote PC and copy install files
New-Item C:\TV-MSI -Type Directory
Copy-Item z:\tv-msi\*.* c:\tv-msi\
#Run the MSI silent install
$msifile= 'C:\TV-MSI\TeamViewer_Host.msi' 
           $arguments= ' /qn' 
Start-Process `
     -file  $msifile `
     -arg $arguments `
     -passthru | wait-process
#Remove and cleanup install files and desktop shortcuts
Remove-Item C:\TV-MSI -Recurse
Start-Process -file 'C:\Program Files (x86)\Teamviewer\Version8\Teamviewer.exe'
Remove-Item "c:\Users\Public\Desktop\Teamviewer 8 Host.lnk"
Net use z: /delete /y
