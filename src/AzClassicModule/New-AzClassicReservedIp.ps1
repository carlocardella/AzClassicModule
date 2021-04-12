function New-AzClassicReservedIp {
    <#
    .SYNOPSIS
        Creates a new ReservedIp
    
    .PARAMETER Name
        The Name of the ReservedIP to return information for
    
    .PARAMETER ResourceGroupName
        The Resource Group containing the Reserved.
        If no ResourceGroupName is specified, the function will automatically create one named "ClassicNetwork-ResourceGroup-<location>"
    
    .PARAMETER Location
        The location where to create the Reserved IP

    .PARAMETER ApiVersion
        The Microsoft.ClassicNetwork api version to use for the "create" operation.
        Default: 2017-11-15
    
    .EXAMPLE
        New-AzClassicReservedIp -Name TestReservedIpEastUs -Location eastus                                                          

        Name              : TestReservedIpEastUs
        ResourceId        : /subscriptions/c1f9ff84-59d6-4f7f-abbd-5dbccf20386e/resourceGroups/ClassicNetwork-ResourceGroup-eastus/providers/Microsoft.ClassicNetwork/ReservedIps/TestReservedIpEastUs
        ResourceName      : TestReservedIpEastUs
        ResourceType      : Microsoft.ClassicNetwork/ReservedIps
        ResourceGroupName : ClassicNetwork-ResourceGroup-eastus
        Location          : eastus
        SubscriptionId    : c1f9ff84-59d6-4f7f-abbd-5dbccf20386e
        Properties        : @{ipAddress=40.76.19.222; status=Created; provisioningState=Succeeded; inUse=False}
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [string]$Location,

        [parameter()]
        [string]$ApiVersion = '2017-11-15'
    )
    
    if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
        $ResourceGroupName = "ClassicNetwork-ResourceGroup-$location"
        if (!(Get-AzResourceGroup -ResourceGroupName $ResourceGroupName -ErrorAction 'SilentlyContinue')) {
            Write-Verbose "Creating Resource Group $ResourceGroupName"
            New-AzResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location | Out-Null
        }
    }
    
    Write-Verbose "Creating Reserved IP $Name"
    New-AzResource -Location $Location -ResourceType 'Microsoft.ClassicNetwork/reservedIps' -ResourceName $Name -ResourceGroupName $ResourceGroupName -ApiVersion $ApiVersion -Force
}