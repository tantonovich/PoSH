#Connect to ESX or vCenter using Connect-VIServer <servername> before running

"Friendly name for the datastore (ex. <san-IP>:<nfs-volume>):"
$friendlyName = Read-Host

$split = $friendlyName.Split(":")
$san = $split[0]
$path1 = $split[1]
$fullPath = "/vol/" + $path1

Write-Host $friendlyName
Write-Host $san
Write-Host $path1
Write-Host $fullPath

get-vmhost | where {$_.Name -like "HOSTNAME*"} | New-Datastore -Nfs -Name $friendlyName -Path $fullPath -NfsHost $san
