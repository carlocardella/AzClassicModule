function Remove-AzClassicReservedIp {
    <#
    .SYNOPSIS
        Deletes the specified ReservedIp

    .PARAMETER Name
        Name of the ReservedIp to delete

    .PARAMETER ResourceGroupName
        The Resource Group containing the ReservedIp

    .PARAMETER ResourceId
        The ResourceId (ArmId) of the ReservedIp to delete

    .PARAMETER ApiVersion
        The Microsoft.ClassicNetwork api version to use for the "read" operation.
        Default: 2017-11-15

    .PARAMETER Force
        Do not prompt the user to confirm the delete operation

    .EXAMPLE
        Remove-AzClassicReservedIp -Name TestReservedIpEastUs -ResourceGroupName ClassicNetwork-ResourceGroup-eastus -Force

        True
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'resourceName')]
        [string]$Name,

        [parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName, ParameterSetName = 'resourceName')]
        [string]$ResourceGroupName,

        [parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'resourceId')]
        [string]$ResourceId,

        [parameter()]
        [string]$ApiVersion = '2017-11-15',

        [parameter()]
        [switch]$Force
    )

    if ($PSCmdlet.ParameterSetName -eq 'resourceId') {
        $uriSegments = $ResourceId -split '/'
        $Name = $uriSegments[7]
        $ResourceGroupName = $uriSegments[3]
    }
    else {
        $subscriptionId = (Get-AzContext).Subscription.Id
        $ResourceId = "/subscriptions/$subscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.ClassicNetwork/reservedIps/$Name"
    }

    if ($Force -or ($PSCmdlet.ShouldProcess("$Name", "Remove ReservedIp"))) {
        if ($Force -or ($PSCmdlet.ShouldContinue("Remove ReservedIp $Name", "Remove ReservedIp"))) {
            Remove-AzResource -ResourceId $ResourceId -ApiVersion $ApiVersion -Force
        }
    }
}