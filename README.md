# Demo repostitory for deploying the Sentinel connectors for OpenCTI using Logic Apps with Terraform

## Description

This repository contains Terraform code for deploying the Logic Apps and custom connectors for the OpenCTI Sentinel connector in Marketplace.

There is some additional steps needed after deploying, like adding in the API key for OpenCTI in the API connection "OpenCTICustomConnector-OpenCTI-GetIndicatorsStream" which should be in the format "Bearer <APIkey>".

Also the Managed Identity needs to be allowed access to Microsoft Graph.

```powershell
$DestinationTenantId = "<<REPLACE-WITH_TENANT-ID>>"
$MsiName = "OpenCTI-ImportToSentinel" # Name of system-assigned or user-assigned managed service identity. (System-assigned use same name as resource).

$oPermissions = @(
  "ThreatIndicators.ReadWrite.OwnedBy"
)

$GraphAppId = "00000003-0000-0000-c000-000000000000" # Don't change this.

Connect-AzAccount -TenantId $DestinationTenantId
$oMsi = Get-AzADServicePrincipal -Filter "displayName eq '$MsiName'"
$oGraphSpn = Get-AzADServicePrincipal -Filter "appId eq '$GraphAppId'"

$oAppRole = $oGraphSpn.AppRole | Where-Object {($_.Value -in $oPermissions) -and ($_.AllowedMemberType -contains "Application")}

Connect-MgGraph -TenantId $DestinationTenantId -Scopes "AppRoleAssignment.ReadWrite.All,Application.Read.All"

foreach($AppRole in $oAppRole)
{
  $oAppRoleAssignment = @{
    "PrincipalId" = $oMSI.Id
    "ResourceId" = $oGraphSpn.Id
    "AppRoleId" = $AppRole.Id
  }
  
  New-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $oAppRoleAssignment.PrincipalId `
    -BodyParameter $oAppRoleAssignment `
    -Verbose
}
```

## Enternal references

- [Github repository](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions/OpenCTI)
