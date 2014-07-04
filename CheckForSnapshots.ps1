$vm = Get-VM
Get-Snapshot $vm | ft VM,Created,PowerState
