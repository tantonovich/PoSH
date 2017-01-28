$TargetDatabase = (((Get-MailboxDatabase -Server:EVS1 | foreach { get-childitem $_.edbFilePath | select-object name,length} | sort -property length)[0].Name).Split(”.edb”))[0]

Enable-Mailbox -Identity:user@domain.com -Database:$TargetDatabase
