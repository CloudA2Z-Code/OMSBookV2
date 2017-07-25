<#
==============================================================
AUTHOR:         	Tao Yang
Runbook Name:   Get-OMSAlertRemediationRunbookJob
DATE:           	19/01/2017
Version:        	1.0
COMMENT:			    Get OMS alert remediation runbook job details
==============================================================
#>
#Variables
$AutomationAccountName = "<Your Automation Account Name>"
$resourceGroupName = '<Your Automation Account Resource Group Name>'
$JobId = '<Runbook Job Id>'

#Login to Azure
Add-AzureRmAccount

#Select Azure subscription
Get-AzureRMSubscription | Out-GridView -OutputMode Single | Select-AzureRmSubscription

#Get Azure Automation runbook job
$Job = Get-AzureRmAutomationJob -AutomationAccountName $AutomationAccountName -ResourceGroupName $resourceGroupName -Id $JobId

#Get Azure Automation runbook job output
$JobOutput = Get-AzureRmAutomationJobOutput -AutomationAccountName $AutomationAccountName -ResourceGroupName $resourceGroupName -Id $JobId