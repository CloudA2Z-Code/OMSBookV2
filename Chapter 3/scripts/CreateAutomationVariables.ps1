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
$ResouceGroupName = "InsideOMS"


# Create AzureSubscriptionID variable
$AzureSubscriptionID = "<your Azure Subscription ID>"
New-AzureRmAutomationVariable `
    -AutomationAccountName $AutomationAccountName `
    -ResourceGroupName $ResouceGroupName `
    -Name AzureSubscriptionID `
    -Encrypted $false `
    -Value $AzureSubscriptionID


# Create OMSWorkspaceID variable
$OMSWorkspaceID = "<your OMS Workspace ID>"
New-AzureRmAutomationVariable `
    -AutomationAccountName $AutomationAccountName `
    -ResourceGroupName $ResouceGroupName `
    -Name OMSWorkspaceID `
    -Encrypted $false `
    -Value $OMSWorkspaceID


# Create OMSWorkspacePrimaryKey variable
$OMSPriamryKey = "<your OMS Priamry Key>"
New-AzureRmAutomationVariable `
    -AutomationAccountName $AutomationAccountName `
    -ResourceGroupName $ResouceGroupName `
    -Name OMSWorkspacePrimaryKey `
    -Encrypted $true `
    -Value $OMSPriamryKey