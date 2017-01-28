$RemoteEx2013Session = New-PSSession -ConfigurationName Microsoft.Exchange `
                                     -ConnectionUri http://agsrex01.corp.agdc.us/PowerShell/ `
                                     -Authentication Kerberos #-Credential (Get-credential)
Import-PSSession $RemoteEx2013Session

Start-Transcript -Path "c:\Import_PST_Log.txt"
Dir \\agsrfp01\d$\pst\*.pst | %{ New-MailboxImportRequest `
    -Name ImportedPST `
    -BatchName agdcImportJob `
    -Mailbox $_.BaseName `
    -FilePath $_.FullName `
    -TargetRootFolder SubFolderInPrimary}
Stop-Transcript
