function New-AzClassicStorageAccount {
    <#
    .SYNOPSIS
    Create a new Classic Storage Account in the specified Region/Location. 
    
    .PARAMETER StorageAccountName
    Name of the Storage Account to be created
    
    .PARAMETER ResourceGroupName
    Name of the resource group in which to add the Storage account
    
    .PARAMETER AccountType
    Specifies the type of the storage account. Valid values are:

    - Standard_LRS
    - Standard_ZRS
    - Standard_GRS
    - Standard_RAGRS
    - Premium_LRS

    Default vaule: Standard_GRS
    https://docs.microsoft.com/en-us/powershell/module/servicemanagement/azure/new-azurestorageaccount
    
    .PARAMETER Location
    The Azure data center location where the storage account is created
    
    .EXAMPLE
    New-AzClassicStorageAccount -StorageAccountName myclassicstorage -Location centralus -Verbose


    Name              : myclassicstorage
    ResourceId        : /subscriptions/3d10448a-b72b-4ccc-b056-2e876c23ccc6/resourceGroups/myclassicstorage/providers/Microsoft.ClassicStorage/storageAccounts/myclassicstorage
    ResourceName      : myclassicstorage
    ResourceType      : Microsoft.ClassicStorage/storageAccounts
    ResourceGroupName : myclassicstorage
    Location          : centralus
    SubscriptionId    : b6944340-19b9-432c-bba2-898873cda3cb
    Properties        : @{provisioningState=Succeeded; status=Created; endpoints=System.Object[]; accountType=Standard-GRS; geoPrimaryRegion=Central US EUAP; statusOfPrimaryRegion=Available; geoSecondaryRegion=East US 2 EUAP; statusOfSecondaryRegion=Available; creationTime=2020-01-24T18:28:34Z}
    
    .NOTES
    https://docs.microsoft.com/en-us/powershell/module/servicemanagement/azure/new-azurestorageaccount
    #>
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName')]
        [string[]]$StorageAccountName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter()]
        [ValidateSet('Standard_LRS', 'Standard_GRS', 'Standard_ZRS', 'Premium_LRS')]
        [string]$AccountType = 'Standard_GRS',

        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [string]$Location
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
            $ResourceGroupName = @($StorageAccountName[0])
        }

        if (! (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction 'SilentlyContinue')) {
            Write-Verbose "Create Resource Group $ResourceGroupName"
            New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        }
    }

    process {
        foreach ($resource in $StorageAccountName) {
            if (!(Get-AzClassicStorageAccount -StorageAccountName $resource)) {
                Write-Verbose "Create Storage Account $resource"
                New-AzResource -Location $Location -ResourceType 'Microsoft.ClassicStorage/storageAccounts' -ResourceName $resource -ResourceGroupName $ResourceGroupName -Force -Properties @{
                    'AccountType' = $AccountType;
                }
            }
            else {
                Write-Verbose "Storage Account $resource already exists"
            }
        }
    }
}