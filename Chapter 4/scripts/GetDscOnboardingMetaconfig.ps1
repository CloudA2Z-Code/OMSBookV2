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
$DSCConfigPath = 'C:\DSCConfig'
$VM = 'ONPREMVM'

# Create folder if do not exits
If (!(Test-path -Path $DSCConfigPath))
{
    New-Item `
        -Path C:\ `
        -ItemType Directory `
        -Name DSCConfig
}

# Create DSC configuration for connection to
# Azure Automation DSC
Get-AzureRmAutomationDscOnboardingMetaconfig `
    -ResourceGroupName $ResourceGroupName `
    -AutomationAccountName $AutomationAccountName `
    -ComputerName $VM `
    -OutputFolder $DSCConfigPath `
    -Force 