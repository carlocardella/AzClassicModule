function Remove-AzClassicService {
    <#
    .SYNOPSIS
    Remove a PaaS v1 Cloud Service and its deployments

    .PARAMETER ServiceName
    The Cloud Service to remove

    .PARAMETER ResourceGroupName
    The Resource Group containing the Cloud Service to remove

    .PARAMETER RemoveDeployment
    Forces to remove the Production and Staging deployments before attempting to remove the Cloud Service

    .PARAMETER Force
    Does not prompt the user to confirm the action

    .EXAMPLE
    Remove-AzClassicService -ServiceName MyClassicService -Force

    True
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName')]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$ResourceGroupName,

        [parameter()]
        [switch]$RemoveDeployment,

        [parameter()]
        [switch]$Force
    )

    foreach ($service in $ServiceName) {
        Write-Verbose $service

        if ($RemoveDeployment) {
            if ($Force -or ($PSCmdlet.ShouldProcess("$service deployment", "Remove"))) {
                if ($Force -or ($PSCmdlet.ShouldContinue("Remove $service deployment?", "Remove Deployment"))) {
                    Write-Verbose "Removing Staging Slot deployment"
                    Remove-AzClassicDeployment -ServiceName $service -Slot 'Staging' -ErrorAction 'SilentlyContinue' -Force

                    Write-Verbose "Removing Production Slot deployment"
                    Remove-AzClassicDeployment -ServiceName $service -Slot 'Production' -ErrorAction 'SilentlyContinue' -Force
                }
            }    
        }

        if ([string]::IsNullOrWhiteSpace($ResourceGroupName)) {
            $ResourceGroupName = Get-AzClassicService -ServiceName $service | Select-Object -ExpandProperty 'ResourceGroupName'
        }

        if ($Force -or ($PSCmdlet.ShouldProcess("$service cloud service", "Remove"))) {
            if ($Force -or ($PSCmdlet.ShouldContinue("Remove $service cloud service?", "Remove Service"))) {
                Write-Verbose "Removing Classic Cloud Service $service"
                Remove-AzResource -ResourceName $service -ResourceGroupName $ResourceGroupName -ResourceType 'Microsoft.ClassicCompute/domainNames' -Force
            }
        }
    }
}