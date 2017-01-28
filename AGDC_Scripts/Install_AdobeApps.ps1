#Map drive for Powershell to use on remote PC
    #New-PSDrive -Name O -PSProvider FileSystem -root \\agsrwd02.corp.agdc.us\d$\Adobe\adobepro\Build
     
#Create dir and copy install files
    
#New-Item C:\Adobe_temp -Type Directory
    #Copy-Item O:\ c:\Adobe_temp -Recurse

#Run the MSI installer silently
    $msifile= 'C:\Adobe_temp\Build\setup.exe' 
    $arguments= ' ' 

    Start-Process `
        -file  $msifile `
        -arg $arguments `
        -passthru | wait-process

#Cleanup temp directory and unmap drive
    Remove-Item C:\Adobe_temp -Recurse
    Remove-PSDrive -Name Installer
