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
$VMName = "CentOS"
$VMResourceGroup = "CentOS"
$VMLocation = "North Europe"
$AutomationAccountURL = "https://we-agentservice-prod-1.azure-automation.net/accounts/b8764b9c-28c4-4e29-ab9c-af5a75e2efbc"
$AutomationAccountPrimaryKey = "YJ8LjoSd8pGlvwR+7P7n+QPedN44OlDJaJSk8OcHlUlAla2cZNd3TowXlHu6qiMdz25QgaSaaHPdB3JV7vxbnw=="

[string]$ProtectedSettings ='{"RegistrationUrl":"' + $AutomationAccountURL + '", RegistrationKey:"' + $AutomationAccountPrimaryKey + '"}';
[string]$Settings          ='{"Mode": "Register"}';

Set-AzureRmVMExtension `
   -VMName $VMName `
   -ResourceGroupName $VMResourceGroup `
   -Publisher 'Microsoft.OSTCExtensions' `
   -Name 'DSCForLinux' `
   -ExtensionType 'DSCForLinux' `
   -TypeHandlerVersion '2.0' `
   -SettingString $Settings `
   -ProtectedSettingString $ProtectedSettings `
   -Location $VMLocation `
   -ErrorAction Stop