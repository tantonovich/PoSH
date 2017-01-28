#Import the PowerCLI snapin for Powershell
Add-PSSnapin VMWare.VimAutomation.Core
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore

#Ask for the name of the VM to be upgraded
$VM = Read-Host 'Enter Virtual Machine Name:'

#Connect to the vCenter server (uses currently logged in user credentials)
Connect-VIServer -Server localhost

$MyVM = Get-VM -Name $VM

#Check to see if VM is booted. If not, boot and wait 3 minutes to allow VMWare Tools to connect
if ($MyVM.PowerState -eq "PoweredOff") {
   Write-Host "Starting" $MyVM
   Start-VM -VM $VM
   Write-Host "Waiting 3 minutes for VM and VMWare Tools to start..."
   Start-Sleep -s 180
}
#Upgrade VMWare Tools to the latest version
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
#Upgrade the VM Hardware Version, do not ask for confirmation
Set-VM -VM $VM -Version v9 -Confirm:$false
#Upgrade the existing NIC to VMXNet3
Get-VM -name $VM| Get-NetworkAdapter | Where { $_.Type -eq "E1000"} | Set-NetworkAdapter -Type "vmxnet3" -Confirm:$false
Get-VM -name $VM| Get-NetworkAdapter | Where { $_.Type -eq "Flexible"} | Set-NetworkAdapter -Type "vmxnet3" -Confirm:$false
#Boot the VM back up
Start-VM -VM $VM
