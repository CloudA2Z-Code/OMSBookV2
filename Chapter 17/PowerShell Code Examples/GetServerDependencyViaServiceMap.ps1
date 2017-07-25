#requires -module AzureRm.Profile

#region User-defined variables
$AADTenantId = '87d30d7b-c929-407b-a814-18032977c890' #Change this to your AAD tenant ID
$SubscriptionId = '9312bd46-c2ea-40a6-aef6-aa492cba6c13' # change this to your Azure subscription ID
$OMSResourceGroup = 'oms-resource-group'
$OMSWorkspaceName = 'oms-workspace-name'
$FocusComputerName = "OMSQL01"
#endregion

#region functions
#Based on the Get-AADToken from Stanislav Zhelyazkov's OMSSearch module https://github.com/slavizh/OMSSearch/blob/master/OMSSearch.psm1
Function Get-AADToken {
       
  [CmdletBinding()]
  [OutputType([string])]
  PARAM (
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateScript({
        try 
        {
            [System.Guid]::Parse($_) | Out-Null
            $true
        } 
        catch 
        {
            $false
        }
    })]
    [Alias('tID')]
    [String]$TenantID,

    [Parameter(Position=1,Mandatory=$true)][Alias('cred')]
    [pscredential]
    [System.Management.Automation.CredentialAttribute()]
    $Credential
  )
  Try
  {
    #make sure AzureRm.Profile module is loaded. This is required to use the Microsoft.IdentityModel.Clients.ActiveDirectory.dll
    Import-module AzureRm.Profile

    $Username       = $Credential.Username
		$Password       = $Credential.Password

    # Set well-known client ID for Azure PowerShell
    $clientId = '1950a258-227b-4e31-a9cf-717495945fc2'

    # Set Resource URI to Azure Service Management API
    $resourceAppIdURI = 'https://management.azure.com/'

    # Set Authority to Azure AD Tenant
    $authority = 'https://login.microsoftonline.com/common/' + $TenantID

    $AADcredential = [Microsoft.IdentityModel.Clients.ActiveDirectory.UserCredential]::new($UserName, $Password)

    # Create AuthenticationContext tied to Azure AD Tenant
    $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authority)

    $authResult = $authContext.AcquireToken($resourceAppIdURI,$clientId,$AADcredential)
    $Token = $authResult.CreateAuthorizationHeader()
  }
  Catch
  {
      $ErrorMessage = 'Failed to aquire Azure AD token.'
      $ErrorMessage += " `n"
      $ErrorMessage += 'Error: '
      $ErrorMessage += $_
      Write-Error -Message $ErrorMessage `
                  -ErrorAction Stop
  }

  $Token
}

#endregion

#region main
#Get OAuth token
$AzureCred = Get-Credential -Message "Enter an credential to sign into Azure"
$AADToken = Get-AADToken -TenantID $AADTenantId -Credential $AzureCred

#Get the start and end time (from 1 hour ago to now)
$UTCNow = [Datetime]::UtcNow
$startTime = $UTCNow.AddHours(-1) | Get-Date -Format s
$endTime = $UTCNow | Get-Date -Format s

#Invoking Service Map REST APIs
$APIURLBase = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups/$OMSResourceGroup/providers/microsoft.operationalinsights/workspaces/$OMSWorkspaceName/features/serviceMap"
$APIVersion = '2015-11-01-preview'
$headers = @{'Authorization'=$AADToken;'Accept'='application/json'}
$headers.Add('Content-Type','application/json')

#Get the machine from Service Map API
$GetMachinesAPIURL = "$APIURLBase/machines?api-version=$APIVersion&startTime=$startTime&endTime=$endTime"
$GetMachinesRequest = Invoke-WebRequest -UseBasicParsing -Uri $GetMachinesAPIURL -Method Get -Headers $headers
$Machines = (ConvertFrom-Json -InputObject $GetMachinesRequest.Content).value
$FocusMachine = $Machines | Where-Object {$_.properties.computername -ieq $FocusComputerName}
If ($FocusMachine -ne $null)
{
  $FocusMachineId = $FocusMachine.id

  #Make GenerateMap call to get machine dependencies
  $GenerateMapAPIURL = "$APIURLBase/generateMap?api-version=$APIVersion"
  $Requestbody = "{'startTime':'$startTime', 'endTime':'$endTime', 'kind':'map:single-machine-dependency', 'machineId':'$FocusMachineId'}"
  $GenerateMapRequest = Invoke-WebRequest -UseBasicParsing -Uri $GenerateMapAPIURL -Method Post -Headers $headers -Body $Requestbody
  $map = (ConvertFrom-Json -InputObject $GenerateMapRequest.Content).map

  #Nodes
  Write-Output "Nodes in the map"
  $map.nodes | Format-List

  #Edges
  Write-Output "The edges (relationship) of the map"
  $map.edges | Format-List

  Write-Output "Network connections"
  $map.edges.connections | Format-List

  Write-Output "Acceptors (processes accepting on a port)"
  $map.edges.acceptors | Format-List
} else {
  Write-Error "The computer $FocusComputerName is not found in the Service Map solution. make sure it is communicating to Service Map between the specified time window."
}

#endregion