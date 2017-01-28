Add-PSSnapin VMWare.VimAutomation.Core

$VM = Read-Host 'Enter Virtual Machine Name:'

Connect-VIServer -Server vcenter

$MyVM = Get-VM -Name $VM

#Check to see if VM is booted. If not, boot and wait for VMWare Tools connection
if ($MyVM.PowerState -eq "PoweredOff") {
   Write-Host "Starting" $MyVM
   Start-VM -VM $VM
   Write-Host "Waiting 2 minutes for VM and VMWare Tools to start..."
   Start-Sleep -s 120
}

Update-Tools $VM -NoReboot

#Initiate Shutdown of the OS on the VM and wait until powered off
if ($MyVM.PowerState -eq "PoweredOn") {
   Write-Host "Shutting Down" $MyVM
   Shutdown-VMGuest -VM $MyVM -Confirm:$false
   #Wait for Shutdown to complete
   do {
      #Wait 5 seconds
      Start-Sleep -s 5
      #Check the power status
      $MyVM = Get-VM -Name $VM
      $status = $MyVM.PowerState
   }until($status -eq "PoweredOff")
}

Set-VM -VM $VM -Version v8 -Confirm:$false

Get-VM -name $VM| Get-NetworkAdapter | Where { $_.Type -eq "E1000"} | Set-NetworkAdapter -Type "vmxnet3" -Confirm:$false

Start-VM -VM $VM