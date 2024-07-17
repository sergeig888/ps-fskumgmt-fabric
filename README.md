# ps-fskumgmt-fabric

## Sample PowerShell script to help with programatic management of MS Fabric F SKUs

This sample code can help Microsoft Fabric tenant admins manage F SKUs programmatically by leveraging Azure resource provider public APIs. Common tasks included in the sample are retrieval of provisioned capacities, capacity status check, capacity pause/restart, scale up or down, update of capacity admins. Note that formal public API documentation and additional guidance for F SKU APIs is expected to be published after January 2024. Check availability of official guidance as this sample comes "as is". It will evolve over time based on user experience and feedback.

## How to use this sample

Requirements:
* Install [Azure PowerShell modules](https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-11.2.0&tabs=powershell&pivots=windows-psgallery)
* User of the PS script has to provide valid Azure subscription credentials when prompted to login. This sample covers common maintenance tasks for already provisioned capacities.

**UPDATE** [2/2/24]: based on initial feedback added helper function and sample code segment to recursively retrieve Entra Id Security Group member UPNs and add them as capacity Admins. Current version of Az API for Fabric F SKUs doesn't support addition of SGs yet.

**UPDATE** [7/17/24]: Azure ARM API is now officially documented. See [Resource Manager](https://learn.microsoft.com/en-us/rest/api/microsoftfabric/operation-groups?view=rest-microsoftfabric-2023-11-01) entry point doc.