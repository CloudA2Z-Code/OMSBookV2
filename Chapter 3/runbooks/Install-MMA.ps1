workflow Install-MMA
{
	param (
        [Parameter(Mandatory=$true)]
        [String] 
        $ServerName          
    )
	
	# Set Error Preference	
	$ErrorActionPreference = "Stop"

	# Get Variables and Credentials
	$DomainCreds = Get-AutomationPSCredential `
                   -Name 'DomainCreds'
	$WorkspaceID = Get-AutomationVariable `
                   -Name 'OMSWorkspaceID'
    $WorkspacePrimaryKey = Get-AutomationVariable `
                           -Name 'OMSWorkspacePrimaryKey'
    $Agent64URL = 'https://go.microsoft.com/fwlink/?LinkId=828603'
    $InstallPath = 'C:\install'
    
    # Create Checkpoint 
    Checkpoint-Workflow

	# Conenct to server with PowerShell session
	inlinescript 
    {
		
	    Try
        {
			if (!(Test-path -Path $Using:InstallPath))
			{
 				 # Create path if does not exists
				 New-Item -ItemType Directory `
                          -Path $Using:InstallPath | out-null
			}
			$AgentPath = $Using:InstallPath + '\' + 'mma.exe'
			
			# Download MMA exe
			Invoke-WebRequest `
            -Uri $Using:Agent64URL `
            -UseBasicParsing `
            -OutFile $AgentPath | Out-Null
			
			$AgentArguments = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=' `
                              + $Using:WorkspaceID + ' OPINSIGHTS_WORKSPACE_KEY=' `
                              + $Using:WorkspacePrimaryKey `
                              + ' AcceptEndUserLicenseAgreement=1"'
			
			Write-Output `
            -InputObject 'Starting MMA installation.'
			
            # Start Installation
			Start-Process `
            -FilePath $AgentPath `
            -ArgumentList $AgentArguments `
            -Wait `
            -NoNewWindow `
            -PassThru | Out-Null
			
            Write-Output `
            -InputObject 'MMA installation finished successfully.'
		}
		Catch
		{
			# Output message if installation fails
			Write-Output `
            -InputObject 'Could not install MMA.'
		}
		
		
	} -PSComputerName $ServerName -PSCredential $DomainCreds


}