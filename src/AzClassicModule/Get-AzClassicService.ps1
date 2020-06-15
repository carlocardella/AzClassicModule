function Get-AzClassicService {
    <#
    .SYNOPSIS
    Returns details about the requested Azure Cloud Service (PaaS).
    
    .PARAMETER ServiceName
    Optional ServiceName(s) to query
    
    .PARAMETER ResourceGroupName
    Optional ResourceGroupName to query

    .PARAMETER ApiVersion
    API version to be used with the ARM call.
    Default: '2019-05-10'
    
    .EXAMPLE
    Get-AzClassicService MyCloudService   

    ServiceName : MyCloudService
    Location    : centraluseuap
    HostName    : MyCloudService.cloudapp.net
    Url         : https://management.core.windows.net/465ac31f-833a-46bd-9cd1-22b57f2df977/services/hostedservices/MyCloudService
    Label       : MyCloudService
    #>
    
    [CmdletBinding()]
    [OutputType("AzClassicService")]
    param (
        [parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('Name', 'ResourceName')]
        [string[]]$ServiceName = "*",

        [parameter(ValueFromPipelineByPropertyName, Position = 1)]
        [string]$ResourceGroupName = "*",

        [parameter()]
        [string]$ApiVersion = '2019-05-10'
    )

    process {
        foreach ($service in $ServiceName) {
            $outObj = $null
            $outObj = Get-AzResource -ApiVersion $ApiVersion -ResourceType 'Microsoft.classicCompute/domainNames' | Where-Object 'ResourceGroupName' -Like $ResourceGroupName | Where-Object 'ResourceName' -Like $service | Get-AzResource
            @($outObj) | ForEach-Object {
                $_ = $_ | Select-Object @{ l = 'Name'; e = { $_.ResourceName } }, ResourceGroupName, ResourceId, Location, @{l = 'Label'; e = { $_.Properties.label } }, @{l = 'HostName'; e = { $_.Properties.hostName } }
                $_ | Add-Member -MemberType NoteProperty -Name 'Url' -Value "https://management.core.windows.net/$((Get-AzContext).Subscription.Id)/services/hostedservices/$($_.Name)"
                $_.PSObject.TypeNames.Insert(0, 'AzClassicService')
                $_
            }
        }
    }
}