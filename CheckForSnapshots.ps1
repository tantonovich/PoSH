Add-PSSnapin VMWare.VimAutomation.Core
Add-PSSnapin VMWare.VimAutomation.Vds


$vmCredential = Get-Credential

Connect-VIserver hqappvc1 -Credential $vmCredential
$vm = Get-VM
Get-Snapshot $vm | ft VM,Created,PowerState

Connect-VIserver aficappvc1 -Credential $vmCredential
$vm = Get-VM
Get-Snapshot $vm | ft VM,Created,PowerState
