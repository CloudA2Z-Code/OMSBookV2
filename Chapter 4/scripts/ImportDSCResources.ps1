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
    -SubscriptionId $Azure.SubscriptionId `
    -TenantId $Azure.TenantId `
    -ErrorAction Stop| Out-Null

# Variables
$ResourceGroupName = 'InsideOMS'
$AutomationAccountName = 'OMSBook'
$xTimeZoneModuleURL = 'https://devopsgallerystorage.blob.core.windows.net/packages/xtimezone.1.6.0.nupkg'
$nxModuleURL = 'https://devopsgallerystorage.blob.core.windows.net/packages/nx.1.0.0.nupkg'

# Import xTimeZone module
# Wait until activities are extracted
New-AzureRmAutomationModule `
    -Name 'xTimeZone' `
    -ContentLink $xTimeZoneModuleURL `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName

# Import nx module
# Wait until activities are extracted
New-AzureRmAutomationModule `
    -Name 'nx' `
    -ContentLink $nxModuleURL `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName