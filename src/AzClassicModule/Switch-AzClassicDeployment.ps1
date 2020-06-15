function Switch-AzClassicDeployment {
    <#
    .SYNOPSIS
    Swaps deployment slots for a PaaS v1 classic Cloud Service
    
    .PARAMETER ServiceName
    The Cloud Service to swap deployments slots for
    
    .PARAMETER ApiVersion
    API version to use with this Resource Provider call
    
    .PARAMETER Force
    Do not prompt the user for confirmation
    
    .EXAMPLE
    Switch-AzClassicDeployment -ServiceName MyClassicService -Force
    #>
    
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('ResourceName')]
        [string[]]$ServiceName,

        [parameter()]
        [string]$ApiVersion = '2015-10-01',

        [parameter()]
        [switch]$Force
    )

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "Service: $service"
            $serviceObject = $null
            $serviceObject = Get-AzClassicService -ServiceName $service

            if ($serviceObject) {
                if ($Force -or ($PSCmdlet.ShouldProcess("$service", "Swap Deployment Slots"))) {
                    if ($Force -or ($PSCmdlet.ShouldContinue("Swap Deployment Slots?", "Swap deployment Slots"))) {
                        Invoke-AzResourceAction -Action 'Swap' -ResourceId $serviceObject.ResourceId -ApiVersion $ApiVersion -Force
                    }
                }
            }
            else {
                Write-Verbose "No deployment found for $service"
            }
        }
    }
}
