Add-PSSnapin VMWare.VimAutomation.Core
"This script will copy the entire contents of E: to the specified datastore"
"Make sure ONLY VM folders are in E!"
"Edit this script to connect to the correct datastore and host BEFORE continuing!"
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
#Specify the correct host below
Connect-VIServer -Server fnb1vs01
#Specify the correct Datastore below
Copy-DatastoreItem -Item E:\* -Destination vmstores:\fnb1vs01@443\ha-datacenter\FNB-3PAR-VS01\ -Recurse
