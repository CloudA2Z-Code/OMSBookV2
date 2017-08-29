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

# Automation Account Name

$AutomationAccountName = "OMSBook"
$ResouceGroupName = "OMS"

# Create AzureCredentials credential

$AureCred = Get-Credential
New-AzureRmAutomationCredential `
    -Name AzureCredentials `
    -AutomationAccountName $AutomationAccountName `
    -ResourceGroupName $ResouceGroupName `
    -Value $AureCred