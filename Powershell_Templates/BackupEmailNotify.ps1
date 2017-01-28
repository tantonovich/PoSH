if ( (Get-PSSnapin -Name Windows.ServerBackup -ErrorAction SilentlyContinue) -eq $null ) 
{ 
    Add-PsSnapin Windows.ServerBackup 
} 

function EmailNotification {
$wbJob = Get-WBJob -Previous 1
if ($wbJob.DetailedMessage -EQ "") {
    $Subject = "<client name> Backup Job Completed"
   } else {
   $Subject = "<client name> Backup Job FAILED"
   }
$hostname = get-content env:ComputerName
$EmailFrom = "<client_backups>@resdat.com"
$EmailTo = "clientalerts_medium@resdat.com" 
$Body = Get-WBJob -Previous 1 | Out-String
$SMTPServer = "smtp.gmail.com" 
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("rdismtp2@gmail.com", "!@#gmail123"); 
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
}
EmailNotification
