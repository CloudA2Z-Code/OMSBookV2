#requires -Version 3.0 -Modules MSOnline
<#
    =====================================================
    AUTHOR:  Tao Yang 
    DATE:    22/01/2017
    Version: 1.0
    Comment: Set Power BI account password never expires
    =====================================================
#>
#Variable
$PowerBIUserName = '<Power BI User Name>'
$AdminCredential = Get-Credential -Message 'Please enter your Office 365 admin credential'

#Sign in to Office 365 / Microsoft Online service
Connect-MsolService -Credential $AdminCredential

#Make password never expires
Set-MsolUser -UserPrincipalName $PowerBIUserName -PasswordNeverExpires $true