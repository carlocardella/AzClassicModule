function Get-AzClassicReservedIp {
    <#
    .SYNOPSIS
        Get ReservedIPs in the current subscription
    
    .PARAMETER Name
        The Name of the ReservedIP to return information for
    
    .PARAMETER ResourceGroupName
        The Resource Group containing the ReservedIp
    
    .PARAMETER ApiVersion
        The Microsoft.ClassicNetwork api version to use for the "read" operation.
        Default: 2017-11-15
    
    .EXAMPLE
        Get-AzClassicReservedIp

        Name              : carloctestreservedip
        ResourceGroupName : ClassicNetwork-ResourceGroup-eastus
        ResourceType      : Microsoft.ClassicNetwork/reservedIps
        Location          : eastus
        ResourceId        : /subscriptions/c1f9ff84-59d6-4f7f-abbd-5dbccf20386e/resourceGroups/ClassicNetwork-ResourceGroup-eastus/providers/Microsoft.ClassicNetwork/reservedIps/carloctestreservedip
        Tags              :

        Name              : TestReservedIpEastUs
        ResourceGroupName : ClassicNetwork-ResourceGroup-eastus
        ResourceType      : Microsoft.ClassicNetwork/reservedIps
        Location          : eastus
        ResourceId        : /subscriptions/c1f9ff84-59d6-4f7f-abbd-5dbccf20386e/resourceGroups/ClassicNetwork-ResourceGroup-eastus/providers/Microsoft.ClassicNetwork/reservedIps/TestReservedIpEastUs
        Tags              :

    .EXAMPLE
        Get-AzClassicReservedIp -Name TestReservedIpEastUs -ResourceGroupName ClassicNetwork-ResourceGroup-eastus | Format-List *

        ResourceId            : /subscriptions/c1f9ff84-59d6-4f7f-abbd-5dbccf20386e/resourceGroups/ClassicNetwork-ResourceGroup-eastus/providers/Microsoft.ClassicNetwork/ReservedIps/TestReservedIpEastUs
        Id                    : /subscriptions/c1f9ff84-59d6-4f7f-abbd-5dbccf20386e/resourceGroups/ClassicNetwork-ResourceGroup-eastus/providers/Microsoft.ClassicNetwork/ReservedIps/TestReservedIpEastUs
        Identity              :
        Kind                  :
        Location              : eastus
        ManagedBy             :
        ResourceName          : TestReservedIpEastUs
        Name                  : TestReservedIpEastUs
        ExtensionResourceName :
        ParentResource        :
        Plan                  :
        Properties            : @{ipAddress=40.76.19.222; status=Created; provisioningState=Succeeded; inUse=False}
        ResourceGroupName     : ClassicNetwork-ResourceGroup-eastus
        Type                  : Microsoft.ClassicNetwork/ReservedIps
        ResourceType          : Microsoft.ClassicNetwork/ReservedIps
        ExtensionResourceType :
        Sku                   :
        Tags                  :
        TagsTable             : 
        SubscriptionId        :
        CreatedTime           :
        ChangedTime           :
        ETag                  :
    #>
    [CmdletBinding()]
    param (
        [parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [parameter(position = 1, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter()]
        [string]$ApiVersion = '2017-11-15'
    )

    if ([string]::IsNullOrWhiteSpace($Name) -and ([string]::IsNullOrWhiteSpace($ResourceGroupName))) {
        Get-AzResource -ResourceType 'Microsoft.ClassicNetwork/reservedIps'
    }
    else {
        Get-AzResource -Name $Name -ResourceGroupName $ResourceGroupName -ResourceType 'Microsoft.ClassicNetwork/reservedIps' -ApiVersion $ApiVersion
    }
}