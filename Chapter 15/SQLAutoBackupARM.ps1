$vmname = "vmname"
$resourcegroupname = "resourcegroupname"
$password = "P@ssw0rd"

$encryptionpassword = $password | ConvertTo-SecureString `
-AsPlainText -Force  

$autobackupconfig = AzureRM.Compute\New-AzureVMSqlServerAutoBackupConfig `
-Enable -RetentionPeriod 10 -EnableEncryption `
-CertificatePassword $encryptionpassword -ResourceGroupName $resourcegroupname

Set-AzureRmVMSqlServerExtension -AutoBackupSettings $autobackupconfig `
-VMName $vmname -ResourceGroupName $resourcegroupname 
