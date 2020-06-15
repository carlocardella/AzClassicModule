function Remove-AzClassicDeployment {
    <#
    .SYNOPSIS
    Removes a Classic Cloud Service deployment
    
    .PARAMETER ServiceName
    The Service to remove the deployment from
    
    .PARAMETER Slot
    Deployent slot to remove
    
    .PARAMETER Force
    Does not prompt the user for confirmation
    
    .EXAMPLE
    Remove-AzClassicDeployment -ServiceName MyClassicService -Verbose -Force -Slot Production
    VERBOSE: Reading MyClassicService Cloud Service details
    VERBOSE: Deployment slot: Production
    VERBOSE: Reading deployment details
    VERBOSE: Reading MyClassicService Cloud Service details
    VERBOSE: Deployment Slot: Production
    VERBOSE: Reading deploment details
    VERBOSE: Remove Resource /subscriptions/87e1661c-f3be-466f-ad6f-7684a4a9a2a8/resourceGroups/MyClassicService/providers/Microsoft.ClassicCompute/domainNames/MyClassicService/slots/Production

    True
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('Name', 'ResourceName')]
        [string[]]$ServiceName,

        [parameter()]
        [ValidateSet('Production', 'Staging')]
        [string]$Slot = 'Production',

        [parameter()]
        [switch]$Force
    )

    process {
        foreach ($service in $ServiceName) {
            $serviceObject = $null
            Write-Verbose "Reading $service Cloud Service details"
            $serviceObject = Get-AzClassicService -ServiceName $service

            if ($serviceObject) {
                foreach ($s in $Slot) {
                    Write-Verbose "Deployment slot: $s"
                    $deploymentObject = $null
                    Write-Verbose "Reading deployment details"
                    $deploymentObject = Get-AzClassicDeployment -ServiceName $serviceObject.ServiceName -Slot $Slot

                    if ($deploymentObject) {
                        if ($Force -or ($PSCmdlet.ShouldProcess($($serviceObject.ServiceName), 'Remove Deployment'))) {
                            if ($Force -or ($PSCmdlet.ShouldContinue("Remove $Slot deploymemt on $($serviceObject.ServiceName)", 'Remove deployment?'))) {
                                Write-Verbose "Remove Resource $($deploymentObject.ResourceId)"
                                Remove-AzResource -ResourceId $deploymentObject.ResourceId -Force
                            }
                        }
                    }
                    else { 
                        Write-Verbose "No deployment found"
                    }
                }
            }
        }
    }
}