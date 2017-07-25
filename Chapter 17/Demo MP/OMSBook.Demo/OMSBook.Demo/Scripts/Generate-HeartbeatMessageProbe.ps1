$Now = Get-Date
$UTCNow = $Now.ToUniversalTime()
$strNow = Get-Date $Now -Format F
$strUTCNow = Get-Date $UTCNow -Format F
$ComputerName = $env:COMPUTERNAME
$Domain = (Get-WmiObject -Query "Select Domain from Win32_ComputerSystem").Domain
$FQDN = "$ComputerName`.$Domain"
$oApi = New-Object -Comobject "MOM.ScriptAPI"

$HeartbeatMessage = "OpsMgr Heartbeat Event. Originating Computer: '$FQDN'. Local Time: '$strNow'. UTC Time: '$strUTCNow'."

#Submit property bag
$oBag = $oAPI.CreatePropertyBag()
$oBag.AddValue("LogTime", $strNow)
$oBag.AddValue("LogUTCTime", $strUTCNow)
$oBag.AddValue("LoggingComputer", $ComputerName)
$oBag.AddValue("HeartbeatMessage", $HeartbeatMessage)
$oBag
