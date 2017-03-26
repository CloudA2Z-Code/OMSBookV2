#requires -Modules AzureRM.OperationalInsights, AzureRM.Profile, AzureRM.Resources
#requires -Version 2.0
#Requires -RunAsAdministrator
<#
    ===============================================================
    AUTHOR:  Tao Yang 
    DATE:    12/01/2017
    Version: 1.1
    Comment: Create Azure Service Principal for SCCM OMS connector
    ===============================================================
#>

Function New-Passowrd
{
  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory = $true)][int]$Length,
    [Parameter(Mandatory = $true)][int]$NumberOfSpecialCharacters
  )
  Add-Type -AssemblyName System.Web
  [Web.Security.Membership]::GeneratePassword($Length,$NumberOfSpecialCharacters)
}

#Login to Azure
Write-Output -InputObject 'Please login to Azure using an admin account of your subscription.'
Disable-AzureRmDataCollection -WarningAction SilentlyContinue
$AzureAccount = Add-AzureRmAccount

#Make sure it's logged in to Azure
try 
{
  $Context = Get-AzureRmContext
}
catch 
{
  throw 'Unable to detect azure context, please make sure you have signed in to Azure.'
  Exit -1
}

#Select Azure subscription
$subscriptions = Get-AzureRmSubscription -WarningAction SilentlyContinue
if ($subscriptions.count -gt 0)
{
  Write-Output -InputObject 'Select Azure Subscription of which the OMS workspace is located'

  $menu = @{}
  for ($i = 1;$i -le $subscriptions.count; $i++) 
  {
    Write-Host -Object "$i. $($subscriptions[$i-1].SubscriptionName)"
    $menu.Add($i,($subscriptions[$i-1].SubscriptionId))
  }
  Do 
  {
    [int]$ans = Read-Host -Prompt "Enter selection (1 - $($i -1))"
  }
  while ($ans -le 0 -or $ans -gt $($i -1))

  $subscriptionID = $menu.Item($ans)
  $subscription = Get-AzureRmSubscription -SubscriptionId $subscriptionID -WarningAction SilentlyContinue
  #$tenant = Get-AzureRmTenant -TenantId $subscription.TenantId
  $null = Set-AzureRmContext -SubscriptionId $subscriptionID
}
else 
{
  Write-Error -Message 'No Azure Subscription found. Unable to continue!'
  Exit -1
}

#Select the OMS workspace
$OMSWorkspaces = Get-AzureRmOperationalInsightsWorkspace
If ($OMSWorkspaces.Count -gt 0)
{
  Write-Output -InputObject 'Select the OMS Workspace of which the SCCM OMS connector will be connected to:'
  $menu = @{}
  $OMSResourceGroups = @{}
  $OMSWorkspaceIDs = @{}
  for ($i = 1;$i -le $OMSWorkspaces.count; $i++) 
  {
    Write-Host -Object "$i. $($OMSWorkspaces[$i-1].Name)"
    $menu.Add($i,($OMSWorkspaces[$i-1].Name))
    $OMSResourceGroups.Add($i,($OMSWorkspaces[$i-1].ResourcegroupName))
    $OMSWorkspaceIDs.Add($i,($OMSWorkspaces[$i-1].CustomerId))
  }

  Do 
  {
    [int]$ans = Read-Host -Prompt "Enter selection (1 - $($i -1))"
  }
  while ($ans -le 0 -or $ans -gt $($i -1))
  $OMSResourceGroup = $OMSResourceGroups.Item($ans)
}
else 
{
  Write-Error -Message 'No OMS Log Analytics workspace detected in the selected Azure subscription. Unable to continue.'
  Exit -1
}
#Get the AAD tenant name
Write-Output -InputObject 'Getting Azure AD tenant name.'
[string[]]$AADTenantNames = (Get-AzureRmADUser |
  Where-Object -FilterScript {
    $_.UserPrincipalName -imatch ".onmicrosoft.com$"
} ).UserPrincipalName |
ForEach-Object -Process {
  $_.split('@')[1]
} |
Get-Unique
If ($AADTenantNames.count -eq 1)
{
  $AADDomainName = $AADTenantNames[0]
  Write-Verbose -Message "Azure AD tenant name: '$AADDomainName'"
}
else 
{
  Write-Output -InputObject 'Select the correct Azure AD tenant name for your Azure subscription:'
  $menu = @{}
  for ($i = 1;$i -le $AADTenantNames.count; $i++) 
  {
    Write-Host -Object "$i. $($AADTenantNames[$i-1])"
    $menu.Add($i,($AADTenantNames[$i-1]))
  }
  Do 
  {
    [int]$ans = Read-Host -Prompt "Enter selection (1 - $($i -1))"
  }
  while ($ans -le 0 -or $ans -gt $($i -1))

  $AADDomainName = $menu.Item($ans)
}

#Create the application
#Application Name
$DefaultApplicationName = 'SCCM-OMS-Connector'
$ApplicationDisplayName = Read-Host -Prompt "Enter application name (or press enter to accept the default name '$DefaultApplicationName')"

if ($ApplicationDisplayName.Length -eq 0) 
{
  $ApplicationDisplayName = $DefaultApplicationName
}
$NewPassword = New-Passowrd -Length 20 -NumberOfSpecialCharacters 0

Write-Output -InputObject 'Creating Azure AD aplication'
$Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ('http://' + $ApplicationDisplayName) -IdentifierUris ('http://' + $ApplicationDisplayName) -Password $NewPassword
Write-Output -InputObject "Creating Azure AD Service Principal for the application '$ApplicationDisplayName'."
$ApplicationServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $Application.ApplicationId
Write-Output -InputObject 'Assigning Service Principal Contributor rights to the OMS resource group.'
$NewRole = $null
$Retries = 0
While ($NewRole -eq $null -and $Retries -le 5)
{
  # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
  Start-Sleep -Seconds 10
  $null = New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId -ResourceGroupName $OMSResourceGroup -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 10
  $NewRole = Get-AzureRmRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
  $Retries++
}
Write-Output -InputObject 'Use the following information to create the SCCM OMS Connector in the SCCM console:'
Write-Output -InputObject "Tenant: '$AADDomainName'"
Write-Output -InputObject "Client ID: '$($Application.ApplicationId)'"
Write-Output -InputObject "Client Secret Key: '$NewPassword'"