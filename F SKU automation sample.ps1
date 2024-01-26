# Written by Sergei Gundorov; v1 development started on 1-19-24
#
# Intent: 1. Provide sample commandlets to manage Microsoft Fabric F SKUs
#            while public API documentation is being refined
#         2. Provide sample syntax guidance for the most common tasks 
#
# NOTE:   While it is possible to use Invoke-AzRestMethod commandlet and not deal with the header related overhead
#         this sample uses pure REST calls to make the syntax usable in all tools/languages that can execute REST calls
#
# Microsoft Fabric F SKUs: https://learn.microsoft.com/en-us/fabric/enterprise/buy-subscription
# Pre-requisite PS module: https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-11.2.0&tabs=powershell&pivots=windows-psgallery

#CONFIG PARAMETERS
$sn = "[subscription name]" #YOUR SUBSCRIPTION NAME


#CAPACITY CONFIG PARAMETERS
$g='[resource group name]'     #YOUR RESOURCE GROUP NAME
$c='[capacity name]'   #YOUR CAPACITY NAME FOR SINGLE CAPACITY OPERATIONS

#connect to your Azure account and subscription that contains F SKUs you need to manage
Connect-AzAccount -Subscription $sn

#capturing subscription ID for Az calls
$s = (Get-AzContext).Subscription.ID

#AUTOMATION OF COMMON TASKS

#IMPORTANT: Execute this block of code first to acquire access token before executing sample lines below

#authorization with bearer token
$token=(Get-AzAccessToken).Token

#NOTE: content type is required only for requests with -Body like PATCH for SKU upgrade
$headers = @{
    "Authorization"="Bearer $token";
    "Content-Type"="application/json"
    }
#end of authorization token acquisition block

#get all capacities using REST call
$capacities = Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities?api-version=2022-07-01-preview" -Headers $headers -Method Get

#alternative way to get all capacities using AzRestMethod that doesn't require injection of header; good option for unattended PS based automation
#note that unlike with the payload above you will need to parse Content property to get to the values
Invoke-AzRestMethod -Path "/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities?api-version=2022-07-01-preview" -Method GET

#get single capacity
$capacity = Invoke-RestMethod -Uri ("https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/"+$c+"?api-version=2022-07-01-preview") -Headers $headers -Method Get

#check capacity status
#IMPORTANT: some capacity operations like the addition or removal of capacity admins require capacity to be in the active state
#use the status property check before executing. If status is 'Paused' call to update admins will not fail, but the list of 
#capacity admins will not be updated 
$status = (Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities?api-version=2022-07-01-preview" -Headers $headers -Method Get).value.properties.State

#resume capacity
$resume = Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/$c/resume?api-version=2022-07-01-preview" -Headers $headers -Method Post

#pause capacity
$pause = Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/$c/suspend?api-version=2022-07-01-preview" -Headers $headers -Method Post

#check capacity admins
#capacity can be in paused state for this operaiton
$admins = (Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities?api-version=2022-07-01-preview" -Headers $headers -Method Get).value.properties.administration

#update capacity admins
#IMPORTANT: capacity needs to be in active state for these commandlets to succeed; capacity status check call must return 'Active'
#addtion or removal of aliases must contain the entire array aliases of who should be capacity admin
#there is no group support at the time of creation of this sample

#admins list for operations to add or remove capacity admins
$a1='{"properties": {"administration": {"members": ["user1@domain.com"]}}}'
$a2='{"properties": {"administration": {"members": ["user1@domain.com","user2@domain.com"]}}}'

$updateAdminsTo1 = Invoke-RestMethod -Uri ("https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/"+$c+"?api-version=2022-07-01-preview") -Body $a1 -Headers $headers -Method Patch

$updateAdminsTo2 = Invoke-RestMethod -Uri ("https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/"+$c+"?api-version=2022-07-01-preview") -Body $a2 -Headers $headers -Method Patch


#SKU definitions
#using strings for simplicity; can use proper arrays and JSON conversion
$f2='{"sku": {"name": "F2","tier": "Fabric"}}'
$f4='{"sku": {"name": "F4","tier": "Fabric"}}'
$f8='{"sku": {"name": "F8","tier": "Fabric"}}'
$f16='{"sku": {"name": "F16","tier": "Fabric"}}'
$f32='{"sku": {"name": "F32","tier": "Fabric"}}'
$f64='{"sku": {"name": "F64","tier": "Fabric"}}'
$f128='{"sku": {"name": "F128","tier": "Fabric"}}'
$f256='{"sku": {"name": "F256","tier": "Fabric"}}'
$f512='{"sku": {"name": "F512","tier": "Fabric"}}'

#scale SKUs up or down
#capacity can be in paused state
$updateToF2 = Invoke-RestMethod -Uri ("https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/"+$c+"?api-version=2022-07-01-preview") -Body $f2 -Headers $headers -Method Patch
$updateToF4 = Invoke-RestMethod -Uri ("https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/"+$c+"?api-version=2022-07-01-preview") -Body $f4 -Headers $headers -Method Patch
$updateToF64 = Invoke-RestMethod -Uri ("https://management.azure.com/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities/"+$c+"?api-version=2022-07-01-preview") -Body $f64 -Headers $headers -Method Patch


#AzRestMehtod alternative to injecting token explicitly with pure REST API
#TODO: need to handle multiple capacities
$capacity=((Invoke-AzRestMethod -Path "/subscriptions/$s/resourceGroups/$g/providers/Microsoft.Fabric/capacities?api-version=2022-07-01-preview" -Method Get).Content | ConvertFrom-Json).value


#TODO: add routine to add alias to all capacities in resource group

#Dynamic array building guidance section

#dynamic payload object build block
#base payload array structure
#TODO: evaluate if possible to leverage API returned object
$admins=@{
    properties = @{
        administration = @{
            members = @()
        }
    }
} 

#this could be a loop iterating over existing list of admins with simple new alias add
#TODO: check duplicate alias handling on Azure side
$admins.properties.administration.members+='user1@domain.com'
$admins.properties.administration.members+='user2@domain.com'

$admins = $admins | ConvertTo-Json -Depth 3 -Compress