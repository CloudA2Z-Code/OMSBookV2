Param ([string]$ComputerName)
$oAPI = New-Object -ComObject "MOM.ScriptAPI"
$ThisScript = "LogicalDiskPercentDiskTimeWMIPerfProbe.ps1"
$oAPI.LogScriptEvent($ThisScript, 1234, 0, "Getting Logical Disk % Disk Time Perf data via WMI for '$ComputerName'.")
Foreach ($item in (Get-WmiObject -ComputerName $ComputerName -Query "Select Name, PercentDiskTime from Win32_PerfRawData_PerfDisk_LogicalDisk"))
{
	$oBag = $oAPI.CreatePropertyBag()
	$oBag.AddValue("Instance", $item.Name)
	$oBag.AddValue("PercentDiskTime", $item.PercentDiskTime)
	$oBag
	#$oAPI.AddItem($oBag)
}
#$oAPI.ReturnItems()

