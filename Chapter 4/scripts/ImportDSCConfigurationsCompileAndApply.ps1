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


# Variables
$ResourceGroupName = 'InsideOMS'
$AutomationAccountName = 'OMSBook'
$DSCConfiguraitonW = "C:\InsideOMSv2\Chap4\configurations\SetTimeZone.ps1"
$ConfigurationNameW = "SetTimeZone"
$VMNameW  = "ONPREMVM"
$DSCNodeConfigurationNameW = "SetTimeZone.TimeZone"
$DSCConfiguraitonL = "C:\InsideOMSv2\Chap4\configurations\SetFileConfiguraiton.ps1"
$ConfigurationNameL = "SetFileConfiguraiton"
$VMNameL  = "CentOS"
$DSCNodeConfigurationNameL = "SetFileConfiguraiton.BaselineServers"

# Import SetTimeZone DSC Configuration
Import-AzureRmAutomationDscConfiguration `
      -SourcePath $DSCConfiguraitonW `
      -Description "Set Time zone." `
      -Published `
      -Force `
      -ResourceGroupName $ResourceGroupName `
      -AutomationAccountName $AutomationAccountName 


# Import SetFileConfiguraiton DSC Configuration
Import-AzureRmAutomationDscConfiguration `
      -SourcePath $DSCConfiguraitonL `
      -Description "Configure a file.." `
      -Published `
      -Force `
      -ResourceGroupName $ResourceGroupName `
      -AutomationAccountName $AutomationAccountName 

# Compile SetTimeZone DSC Configuration
$CompilationJob = Start-AzureRmAutomationDscCompilationJob `
                            -ResourceGroupName $ResourceGroupName `
                            -AutomationAccountName $AutomationAccountName  `
                            -ConfigurationName $ConfigurationNameW

# Wait for Complication to finish
while($null -eq $CompilationJob.EndTime -and $null -eq $CompilationJob.Exception)           
{
    $CompilationJob = $CompilationJob | Get-AzureRmAutomationDscCompilationJob `
                                          -ErrorAction Stop
    
    Start-Sleep -Seconds 3
}
If ($null -ne $CompilationJob.Exception)
{
    $ErrorMessage = "Compilation job with ID $($CompilationJob.id) failed."
    $ErrorMessage += " `n"
    $ErrorMessage += 'Error: '
    $ErrorMessage += $CompilationJob.Exception
    Write-Error -Message $ErrorMessage `
                -ErrorAction Stop
}

# Compile SetFileConfiguraiton DSC Configuration
$CompilationJob1 = Start-AzureRmAutomationDscCompilationJob `
                            -ResourceGroupName $ResourceGroupName `
                            -AutomationAccountName $AutomationAccountName  `
                            -ConfigurationName $ConfigurationNameL

# Wait for Complication to finish
while($null -eq $CompilationJob1.EndTime -and $null -eq $CompilationJob1.Exception)           
{
    $CompilationJob1 = $CompilationJob1 | Get-AzureRmAutomationDscCompilationJob `
                                          -ErrorAction Stop
    
    Start-Sleep -Seconds 3
}
If ($null -ne $CompilationJob1.Exception)
{
    $ErrorMessage = "Compilation job with ID $($CompilationJob1.id) failed."
    $ErrorMessage += " `n"
    $ErrorMessage += 'Error: '
    $ErrorMessage += $CompilationJob1.Exception
    Write-Error -Message $ErrorMessage `
                -ErrorAction Stop
}

# Get Windows DSC Node
$NodeObjW = Get-AzureRmAutomationDscNode `
            -Name $VMNameW `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $AutomationAccountName

# Get Linux DSC Node
$NodeObjL = Get-AzureRmAutomationDscNode `
            -Name $VMNameL `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $AutomationAccountName

# Get DSC Node Configuration SetTimeZone.TimeZone
$ConfigurationObjW = Get-AzureRmAutomationDscNodeConfiguration `
                        -Name $DSCNodeConfigurationNameW `
                        -ResourceGroupName  $ResourceGroupName `
                        -AutomationAccountName $AutomationAccountName 


# Get DSC Node Configuration SetFileConfiguraiton.BaselineServers
$ConfigurationObjL = Get-AzureRmAutomationDscNodeConfiguration `
                        -Name $DSCNodeConfigurationNameL `
                        -ResourceGroupName  $ResourceGroupName `
                        -AutomationAccountName $AutomationAccountName 

# Assing configuration to node (Windows)
Set-AzureRmAutomationDscNode `
            -NodeConfigurationName $ConfigurationObjW.Name `
            -Id  $NodeObjW.Id `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $AutomationAccountName  `
            -Force 


# Assing configuration to node (Linux)
Set-AzureRmAutomationDscNode `
            -NodeConfigurationName $ConfigurationObjL.Name `
            -Id  $NodeObjL.Id `
            -ResourceGroupName $ResourceGroupName `
            -AutomationAccountName $AutomationAccountName  `
            -Force 