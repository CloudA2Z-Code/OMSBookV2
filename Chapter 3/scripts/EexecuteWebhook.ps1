$WebhookURI = "https://s2events.azure-automation.net/webhooks?token=HRnj9O4kUgDTLCvTMOFgtgwPnXKgJVG%2fD4PxWPe7tCQ%3d"
$headers = @{"AuthorizationValue"="OMSBook"}

$WebhookBody  = @([pscustomobject]@{VMName="OMSVM";VMResourceGroup="OMSVM";VMLocation="North Europe"})
$body = ConvertTo-Json -InputObject $WebhookBody

$response = Invoke-WebRequest -Method Post -Uri $WebhookURI -Headers $headers -Body $body
$response 
$jobid = (ConvertFrom-Json ($response.Content)).jobids[0]
$jobid 