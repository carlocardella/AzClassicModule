function Reset-AzClassicDeployment {
    <#
    .SYNOPSIS
    Starts or Stops a PaaS v1 classic service deployment
    
    .PARAMETER ServiceName
    Cloud Service name to start or stop
    
    .PARAMETER Slot
    Deployment Slot to start or stop
    
    .PARAMETER Action
    Action to perform.
    Possible values: Start, Stop
    
    .PARAMETER ApiVersion
    API version to use for this Resource Provider action
    
    .PARAMETER Force
    Does not prompt the user to confirm the action
    
    .EXAMPLE
    Reset-AzClassicDeployment -ServiceName MyClassicService -Action Start -Force

    True
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName', 'Name')]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string[]]$Slot = 'Production',

        [parameter(Mandatory)]
        [ValidateSet('Start', 'Stop')]
        [string]$Action,

        [parameter()]
        [string]$ApiVersion = '2016-11-01',

        [parameter()]
        [switch]$Force
    )

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "Service: $service"
            foreach ($sl in $Slot) {
                Write-Verbose "Slot: $sl"
                $deploymentObject = $null
                $deploymentObject = Get-AzClassicDeployment -ServiceName $service -Slot $sl -ApiVersion $ApiVersion
                Write-Verbose "Deployment ResourceId: $($deploymentObject.ResourceId)"

                if ($Force -or ($PSCmdlet.ShouldProcess($service, $Action))) {
                    if ($Force -or ($PSCmdlet.ShouldContinue($service, $Action))) {
                        Invoke-AzResourceAction -ApiVersion $ApiVersion -Action $Action -ResourceId $deploymentObject.ResourceId -Force
                        $true
                    }
                }
            }
        }
    }
}