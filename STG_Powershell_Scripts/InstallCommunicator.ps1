#DON'T FORGET TO ENTER DOMAIN CREDENTIALS
#Map drive for Powershell to use on remote PC
Net use z: "\\server3\stgdata\IT\Software\other\Shoretel Communicator v13" /user:<REDACTED>
#Create dir and copy install files
New-Item C:\Comm_temp -Type Directory
Copy-Item z:\\*.* c:\Comm_temp\
#Run the MSI installer silently
$msifile= 'C:\Comm_temp\ShoreTel Communicator.msi' 
           $arguments= ' /qn' 
Start-Process `
     -file  $msifile `
     -arg $arguments `
     -passthru | wait-process
#Cleanup temp directory and unmap drive
Remove-Item C:\Comm_temp -Recurse
Net use z: /delete /y