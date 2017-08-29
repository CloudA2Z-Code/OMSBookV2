# Provide credentials
$Creds = Get-Credential `
            -Message 'Provide Azure Subscription Credentials...'

# Login to Azure
Login-AzureRmAccount `
    -Credential $Creds `
    -ErrorAction Stop | Out-Null

# Pick Subscription/TenantID
$Azure =
    (Get-AzureRmSubscription `
        -ErrorAction Stop |
     Out-GridView `
        -Title 'Select a Subscription/Tenant ID...' `
        -PassThru)

# Select Subscription
Select-AzureRmSubscription `
    -SubscriptionId $Azure.Id `
    -TenantId $Azure.TenantId `
    -ErrorAction Stop| Out-Null


$OMSWorkspaceResourceGroup = "OMS"
$OMSWorkspaceName = "Contoso"
$Query = "Type:Update"

$results = Get-AzureRmOperationalInsightsSearchResults `
            -ResourceGroupName $OMSWorkspaceResourceGroup `
            -WorkspaceName $OMSWorkspaceName `
            -Top 200 `
            -Query $Query `
            -Start (Get-Date).AddHours(-12) `
            -End (Get-Date)

Write-Output "Search ID is $($results.id)"
Write-Output 'First Result:'
$results.Value[0]

Write-Output 'All Results:'
$results.Value
