workflow Install-OMSExtensionV2VMWorkflow
{
	param (
        [Parameter(Mandatory=$true)]
        [String] 
        $VMName,

        [Parameter(Mandatory=$true)]
        [String] 
        $VMResourceGroup,

        [Parameter(Mandatory=$true)]
        [String] 
        $VMLocation          
    )
	
    # Set Error Preference	
	$ErrorActionPreference = "Stop"

	# Get Variables and Credentials
	$AzureSubscriptionID    = Get-AutomationVariable `
                                -Name 'AzureSubscriptionID'
	$OMSWorkspaceID         = Get-AutomationVariable `
                                -Name 'OMSWorkspaceID'
    $OMSWorkspacePrimaryKey = Get-AutomationVariable `
                                -Name 'OMSWorkspacePrimaryKey'
	$AzureCred              = Get-AutomationPSCredential `
                                -Name 'AzureCredentials'
	# Create Checkpoint 
    Checkpoint-Workflow

    inlinescript
    {
        Try
        {
            # Authenticate
	        $AzureAccount = Login-AzureRmAccount `
                            -Credential $Using:AzureCred `
                            -SubscriptionId $Using:AzureSubscriptionID `
                            -ErrorAction Stop
        }
        Catch
        {
            $ErrorMessage = 'Login to Azure failed.'
            $ErrorMessage += " `n"
            $ErrorMessage += 'Error: '
            $ErrorMessage += $_
            Write-Error `
            -Message $ErrorMessage `
            -ErrorAction Stop
        }
        
	
	    # Set Variables
	    [string]$Settings          ='{"workspaceId":"' + $Using:OMSWorkspaceID + '"}';
	    [string]$ProtectedSettings ='{"workspaceKey":"' + $Using:OMSWorkspacePrimaryKey + '"}';
	
	    # Start extension installation
	    Write-Output `
        -InputObject 'OMS Extension Installation Started.'
	    
        Try
        {
            $ExtenstionStatus = Set-AzureRmVMExtension `
                                -ResourceGroupName $Using:VMResourceGroup `
                                -VMName $Using:VMName `
                                -Name 'OMSExtension' `
                                -Publisher 'Microsoft.EnterpriseCloud.Monitoring' `
                                -TypeHandlerVersion '1.0' `
                                -ExtensionType 'MicrosoftMonitoringAgent' `
                                -Location $Using:VMLocation `
                                -SettingString $Settings `
                                -ProtectedSettingString $ProtectedSettings `
                                -ErrorAction Stop
        }
        Catch
        {
            $ErrorMessage = 'Failed to install OMS extension on Azure V2 VM.'
            $ErrorMessage += " `n"
            $ErrorMessage += 'Error: '
            $ErrorMessage += $_
            Write-Error `
            -Message $ErrorMessage `
            -ErrorAction Stop
        }
        
	    # Output results
	    If ($ExtenstionStatus.IsSuccessStatusCode  -eq 'True')
	    {
    	    Write-Output `
                -InputObject 'OMS Extension was installed successfully.'
	    }
	    Else
	    {
    	    Write-Output `
                -InputObject 'OMS Extension was not installed.'
            
            Write-Error `
                -Message $ExtenstionStatus.StatusCode `
                -ErrorAction Stop
	    }
    }
}