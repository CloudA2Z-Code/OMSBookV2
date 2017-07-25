#AzureRM.OperationalInsights cmdlets examples

#region login to Azure Subscription
#Login to Azure
Add-AzureRmAccount

#Select Azure Subscription
Get-AzureRmSubscription | Out-GridView -PassThru | Select-AzureRmSubscription
#endregion

#region Get Workspace details
#Get Workspace
$Workspace = Get-AzureRmOperationalInsightsWorkspace -Name "OMSBook" -ResourceGroupName "omsrg"

#Workspace ID
$WorkspaceID = $Workspace.CustomerId
Write-Output "Workspace Id: '$WorkspaceID'"

#Workspace location and SKU
$Location = $workspace.Location
$SKU = $Workspace.sku
Write-Output "WOrkspace location: $Location"
Write-Output "Workspace Pricing Model: $SKU"

#Open portal in default browser
$PortalUrl = $Workspace.PortalUrl
Invoke-Expression "$env:SystemRoot\System32\rundll32.exe url.dll,FileProtocolHandler '$PortalUrl'"

#Get workspace primary and secondary keys
$Keys = Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName "omsrg" -Name "OMSBook"
$PrimaryKey = $Keys.PrimarySharedKey
$SecondaryKey = $Keys.SecondarySharedKey
Write-Output "Primary Key: '$PrimaryKey'"
Write-Output "Secondary Key: '$SecondaryKey'"
#endregion

#region Working with OMS solutions
#Get all solutions that are available for your workspace
Get-AzureRmOperationalInsightsIntelligencePacks -ResourceGroupName "omsrg" -WorkspaceName "OMSBook"

#Get all solutions that are yet enabled in your workspace
Get-AzureRmOperationalInsightsIntelligencePacks -ResourceGroupName "omsrg" -WorkspaceName "OMSBook" | Where-Object {$_.Enabled -eq $false}

#Enable a solution - WIreData solution
Set-AzureRmOperationalInsightsIntelligencePack -ResourceGroupName "omsrg" -WorkspaceName "OMSBook" -IntelligencePackName 'WireData'  -Enabled $true

#Disable a solution - SQL Assessment
Set-AzureRmOperationalInsightsIntelligencePack -ResourceGroupName "omsrg" -WorkspaceName "OMSBook" -IntelligencePackName 'SQLAssessment'  -Enabled $false
#endregion

#region Log Search
#Invoking a search query
$Query = "Type=Event EventLog=System EventID=7036"

$response = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName "omsrg" -WorkspaceName "OMSBook" -Query $Query
$arrResults = New-Object System.Collections.ArrayList
Foreach ($item in $response.Value)
{
    [void]$arrResults.Add($(ConvertFrom-JSON $item))
}
$arrResults

#Invoking a saved search
$SavedSearchDisplayName = 'Planning: Event Counts'

$SavedSearchRequest = Get-AzureRmOperationalInsightsSavedSearch -ResourceGroupName 'omsrg' -WorkspaceName 'OMSBook'
$SavedSearch = $SavedSearchRequest.Value | Where-Object {$_.Properties.DisplayName -ieq $SavedSearchDisplayName}
$SavedSearchId = $SavedSearch.Id.split("/")[9]
$SearchResult = Get-AzureRmOperationalInsightsSavedSearchResults -ResourceGroupName 'omsrg' -WorkspaceName 'OMSBook' -SavedSearchId $SavedSearchId
$arrResults = New-Object System.Collections.ArrayList
Foreach ($item in $SearchResult.Value)
{
    [void]$arrResults.Add($(ConvertFrom-JSON $item))
}
$arrResults
#endregion
