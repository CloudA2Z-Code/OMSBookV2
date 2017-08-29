$storageaccount = "<storageaccountname>"
$storageaccountkey = (Get-AzureStorageKey `
-StorageAccountName $storageaccount).Primary

$storagecontext = New-AzureStorageContext `
-StorageAccountName $storageaccount -StorageAccountKey $storageaccountkey

$autobackupconfig = New-AzureVMSqlServerAutoBackupConfig `
-StorageContext $storagecontext -Enable -RetentionPeriod 10

Get-AzureVM -ServiceName <vmservicename> -Name <vmname> | `
Set-AzureVMSqlServerExtension -AutoBackupSettings ` 
$autobackupconfig | Update-AzureVM
