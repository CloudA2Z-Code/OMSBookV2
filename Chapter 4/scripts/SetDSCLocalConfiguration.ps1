# Variables
$VM = 'ONPREMVM'

# Set Local DSC Configuration to connect to
# Azure Automation DSC

Set-DscLocalConfigurationManager `
    -Path 'C:\DscMetaConfigs\' `
    -ComputerName $VM `
    -Verbose