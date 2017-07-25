<#
=========================================================================
AUTHOR:         	Tao Yang
Runbook Name:   webhookDataHandlerSample
DATE:           	19/01/2017
Version:        	1.0
COMMENT:			    Demonstrate how to retrieve information from webhookdata
=========================================================================
#>
param ([object]$WebHookData)
#Process inputs from webhook data
#Get webhook name
$WebhookName    =   $WebhookData.WebhookName

#Get request header from webhookdata
$webhookHeader =   $WebhookData.RequestHeader

#Get request body from webhookdata
$WebhookBody    =   $WebhookData.RequestBody

#Convert request body from JSON payload to PSObjects
$objWebhookBody = ConvertFrom-JSON $WebhookBody

#Get search result from the request body
$SearchResults = $objWebhookBody.SearchResults
#the webhookdata JSON payload between runbook and generic webhook is slightly different. One uses SearchResults and another uses SearchResult
If ($SearchResults -eq $null)
{
  $SearchResults = $objWebhookBody.SearchResult
}

#Detect if the runbook is triggered by runbook remediation or custom webhook remediation
$UserAgent = $webhookHeader.'User-Agent'
If ($UserAgent -ieq 'oms-remediation')
{
  #Triggered by runbook remediation
  Write-Output "This runbook is triggered by OMS alert runbook remediation."
} elseif ($UserAgent -ieq 'oms-webhook') {
  #Triggered by custom webhook
  Write-Output "This runbook is triggered by OMS alert custom webhook remediation."
} else {
  Write-Output "User Agent: '$UserAgent'. Don't know how it is triggered."
}
#Get Search result Id
$SearchResultsId = $SearchResults.id
Write-Output "Search Result Id: '$SearchResultsId'."

#Get search result value (records returned from search query)
$SearchResultsValue = $SearchResults.value
Write-Output "Search result records:"
Write-Output $SearchResultsValue

#Get meta data
$SearchResultsMetaData = $SearchResults.__metadata
Write-Output "Metadata: '$SearchResultsMetaData'"

### If triggered by custom webhook, you can also retrieve the following information
If ($UserAgent -ieq 'oms-webhook')
{
  #OMS Worksppace Id
  $WorkspaceId = $objWebhookBody.WorkspaceId
  Write-Output "Workspace Id: '$WorkspaceId'."

  #Alert rule name
  $AlertRuleName = $objWebhookBody.AlertRuleName
  Write-Output "Alert Rule Name: '$AlertRuleName'."

  #Search query
  $SearchQuery = $objWebhookBody.SearchQuery
  Write-Output "Search query: '$SearchQuery'."

  #Search Interval Start Time Utc
  $SearchIntervalStartTimeUtc = $objWebhookBody.SearchIntervalStartTimeUtc
  #Convert Search Interval Start Time UTC to datetime object
  $dtSearchIntervalStartTimeUtc = [datetime]::Parse($SearchIntervalStartTimeUtc)
  Write-Output "Search Interval Start Time Utc: '$dtSearchIntervalStartTimeUtc'."

  #Search Interval End time Utc
  $SearchIntervalEndtimeUtc = $objWebhookBody.SearchIntervalEndtimeUtc
  #Convert Search Interval End time Utc to datetime object
  $dtSearchIntervalEndtimeUtc = [datetime]::Parse($SearchIntervalEndtimeUtc)
  Write-Output "Search Interval End Time Utc: '$dtSearchIntervalEndtimeUtc'."

  #Alert Threshold Operator
  $AlertThresholdOperator = $objWebhookBody.AlertThresholdOperator
  Write-Output "Alert Threshold Operator: '$AlertThresholdOperator'."

  #alert Threshold Value
  $AlertThresholdValue = $objWebhookBody.AlertThresholdValue
  Write-Output "Alert Threshold Value: '$AlertThresholdValue'."

  #Result Count
  $ResultCount = $objWebhookBody.ResultCount
  Write-Output "Result Count: '$ResultCount'."

  #Search Interval In Seconds
  $SearchIntervalInSeconds = $objWebhookBody.SearchIntervalInSeconds
  Write-Output "Search Interval In Seconds: '$SearchIntervalInSeconds'."

  #Link to search results
  $LinkToSearchResults = $objWebhookBody.LinkToSearchResults
  Write-Output "Link to search results: '$LinkToSearchResults'."

  #Description
  $Description = $objWebhookBody.Description
  Write-Output "Description: '$Description'."
}
