$TargetDatabase = (((Get-Mailbox -ResultSize:Unlimited | Group-Object -Property:Database | Select-Object Name,Count | Sort-Object -Property:Count)[0].Name).Split(”.edb”))[0]

Enable-Mailbox -Identity:user@domain.com -Database:$TargetDatabase
