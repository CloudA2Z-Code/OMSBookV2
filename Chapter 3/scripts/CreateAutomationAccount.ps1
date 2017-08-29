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

# Create Resource Group

New-AzureRmResourceGroup `
    -Name 'InsideOMS2' `
    -Location "West Europe"

# Create Automation Account 

New-AzureRmAutomationAccount `
    -ResourceGroupName 'InsideOMS2' `
    -Name 'OMSBook23' `
    -Location "West Europe" `
    -Plan Free 