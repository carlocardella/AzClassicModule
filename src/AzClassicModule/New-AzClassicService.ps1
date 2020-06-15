function New-AzClassicService {
    <#
    .SYNOPSIS
    Creates a new empty PaaS v2 Cloud Service. 
    If the ResourceGroupName is not specificed, the cmdlet will use the name of the first Cloud Service passed as name for the resource group
    
    .PARAMETER ServiceName
    The name of the Cloud Service to create
    
    .PARAMETER ResourceGroupName
    The name of the Resource Group that will host the Cloud Service. 
    If the ResourceGroupName is not specificed, the cmdlet will use the name of the first Cloud Service passed as name for the resource group
    
    .PARAMETER Location
    The Azure Location (Region) where the Resource Group and Cloud Service will be created.
    For further details see:
    - Azure Regions: https://azure.microsoft.com/en-us/global-infrastructure/regions/
    - Products available by region: https://azure.microsoft.com/en-us/global-infrastructure/services/
    
    .EXAMPLE
    New-AzClassicService -ServiceName MyClassicService -Location westeurope -Verbose

    VERBOSE: Service MyClassicService

    Name              : MyClassicService
    ResourceId        : /subscriptions/4464c5c9-4718-427f-9036-70ad0250d664/resourceGroups/MyClassicService/providers/Microsoft.ClassicCompute/domainNames/MyClassicService
    ResourceName      : MyClassicService
    ResourceType      : Microsoft.ClassicCompute/domainNames
    ResourceGroupName : MyClassicService
    Location          : westeurope
    SubscriptionId    : de4632d2-ebf4-4b79-bc74-190a91d57c7d
    Properties        : @{provisioningState=Succeeded; status=Created; label=MyClassicService; hostName=MyClassicService.cloudapp.net}
    #>
    
    [CmdletBinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName')]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [string]$Location
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
            $ResourceGroupName = @($ServiceName[0])
        }

        if (! (Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction 'SilentlyContinue')) {
            Write-Verbose "Create Resource Group $ResourceGroupName"
            New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        }
    }

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "Service $service"
            New-AzResource -ResourceType 'Microsoft.ClassicCompute/domainNames' -ResourceName $service -ResourceGroupName $ResourceGroupName -Location $Location -Force
        }
    }
}