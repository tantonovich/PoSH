New-PSDrive -Name User -PSProvider FileSystem -root \\corp.agdc.us\share\users
Import-Csv c:\Users\tantonovich.AGDC\Documents\ASAP.csv | foreach {
    $folder = $_.SamAccountName
    #Add commands here, examples below are to run an installer script on each PC
    $acl = Get-Acl User:\$folder 
    $acl.SetAccessRuleProtection($True,$False)
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("AGDC\ASAP-USER_FOLDER_ADMIN_RO","Read","ContainerInherit,ObjectInherit","None","Allow")
    $acl.AddAccessRule($rule)
    Set-Acl User:\$folder $acl
    Write-Host "Script has been executed on" $pc
    Write-Host "********************************"
        }
Remove-PSDrive User
