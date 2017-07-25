#requires -Modules AzureRM.OperationalInsights, AzureRM.profile
<#
===========================================================
AUTHOR:  Tao Yang
SCRIPT:  New-OMSSavedSearch.PS1
DATE:    20-01-2017
Version: 1.0
Comment: Demo creating OMS saved searhces using PowerShell
===========================================================
#>
#region Defining variables
$resourceGroupName = '<Your OMS Workspace Resource Group Name>'
$OMSWorkspaceName = '<Your OMS Workspace  Name>'
$Category = 'OMS Book'
$Name = 'Windows System Time Changed Events'
$Query = 'Type=Event EventLog=System Source="Microsoft-Windows-Kernel-General" EventID=1'

#You can either name the saved search as "<Category>|<Name>", or just use a random GUID.
$SavedSearchId = "$Category`|$Name"
#$SavedSearchId = [GUID]::NewGuid().Tostring()
#endregion

#region Login to Azure
Add-AzureRmAccount

#Select Azure subscription
Get-AzureRmSubscription |
Out-GridView -OutputMode Single |
Set-AzureRmContext
#endregion

#region Create saved searches
Write-Output -InputObject "Creating saved search - Category: '$Category', Display Name: '$Name', Search Query: '$Query'"

$NewSavedSearch = New-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName -SavedSearchId $SavedSearchId -DisplayName $Name -Category $Category -Query $Query -Version 1
#endregion

#region Get the saved search
Write-Output -InputObject "Getting the saved search - Category: '$Category', Display Name: '$Name', Search Query: '$Query'"
$SavedSearches = Get-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName
Foreach ($item in $SavedSearches.Value)
{
  Write-Output -InputObject "Id: $($item.Id)"
  Write-Output -InputObject "Display Name: $($item.Properties.DisplayName)"
  Write-Output -InputObject "Category: $($item.Properties.Category)"
  Write-Output -InputObject "Query: $($item.Properties.Query)"
  Write-Output -InputObject "Version: $($item.Properties.Version)"
  Write-Output -InputObject ''
}
#endregion

#region Invoke saved search (Get Saved Search Result)
Write-Output -InputObject "Invoking the saved search - Category: '$Category', Display Name: '$Name', Search Query: '$Query'"
#Get the saved search
$SavedSearch = (Get-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName).Value | Where-Object -FilterScript {
  $_.Properties.DisplayName -ieq $Name -and $_.Properties.Category -ieq $Category
}

#Get the Saved Search ID
$SavedSearchIdSplit = $SavedSearch.Id.split('/')
$SavedSearchId = $SavedSearchIdSplit[$SavedSearchIdSplit.count -1]

#Get the saved search result
$SearchResults = @()
Foreach ($item in (Get-AzureRmOperationalInsightsSavedSearchResults -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName -SavedSearchId $SavedSearchId).value)
{
  $SearchResults += ConvertFrom-Json -InputObject $item.tostring()
}
$SearchResults
#endregion

#region Updating Saved Search
Write-Output -InputObject "updating the saved search query - Category: '$Category', Display Name: '$Name'"
$NewQuery = 'Type=Event EventLog=System Source="Microsoft-Windows-Kernel-General" EventID=1 EventLevelName=information'
Write-Output -InputObject "Current Query: '$Query'"
Write-Output -InputObject "New Query: '$NewQuery'"
#Get the saved search ID
$SavedSearch = (Get-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName).Value | Where-Object -FilterScript {
  $_.Properties.DisplayName -ieq $Name -and $_.Properties.Category -ieq $Category
}
$SavedSearchIdSplit = $SavedSearch.Id.split('/')
$SavedSearchId = $SavedSearchIdSplit[$SavedSearchIdSplit.count -1]
$updateSavedSearch = Set-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName -SavedSearchId $SavedSearchId -Category $Category -DisplayName $Name -Query $NewQuery -Version 1 -ETag *
#endregion

#region deleting saved search
Write-Output -InputObject "Deleting the saved search query - Category: '$Category', Display Name: '$Name'"
#Get the saved search ID
$SavedSearch = (Get-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName).Value | Where-Object -FilterScript {
  $_.Properties.DisplayName -ieq $Name -and $_.Properties.Category -ieq $Category
}
$SavedSearchIdSplit = $SavedSearch.Id.split('/')
$SavedSearchId = $SavedSearchIdSplit[$SavedSearchIdSplit.count -1]
$DeleteSavedSearch = Remove-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $resourceGroupName -WorkspaceName $OMSWorkspaceName -SavedSearchId $SavedSearchId
#endregion
Write-Output -InputObject 'Done!'