Add-PSSnapin VMWare.VimAutomation.Core

$MyVM = Read-Host 'Enter Virtual Machine Name (CASE SENSITIVE):'

Connect-VIServer -Server fnb1vc01

Initiate Shutdown of the OS on the VM and wait until powered off
if ($MyVM.PowerState -eq "PoweredOn") {
   Write-Host "Shutting Down" $MyVM
   Shutdown-VMGuest -VM $MyVM -Confirm:$false
   #Wait for Shutdown to complete
   do {
      #Wait 5 seconds
      Start-Sleep -s 5
      #Check the power status
      $MyVM = Get-VM -Name $MyVM
      $status = $MyVM.PowerState
   }until($status -eq "PoweredOff")
}

$vmDS = Get-Datastore -VM $MyVM
$VMPath = "vmstores:\fnb1vc01@443\GCI-IT\" + $vmDS + "\" + $MyVM
Write-Host $VMPath
Set-Location $VMPath
$NewDir = "e:\" + $MyVM
mkdir $NewDir
Copy-DatastoreItem -Item *.* -Destination $NewDir
