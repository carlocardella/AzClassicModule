function Set-AzClassicRole {
    <#
    .SYNOPSIS
    Scale a Classic Service Role
    
    .PARAMETER ServiceName
    The Cloud Service to scale
    
    .PARAMETER Slot
    The deployment slot to scale.
    Default: Production
    
    .PARAMETER RoleName
    The Cloud Service Role to scale
    Default: all roles will be scaled to the specificed number of instances
    
    .PARAMETER Count
    The new number of instances to scale the Cloud Service Role.
    This must be a positive number (greater than 0)
    
    .PARAMETER ApiVersion
    API version to use to execute the command.
    Default: 2016-11-01
    
    .PARAMETER Force
    Suppresses the confirmation prompt
    
    .EXAMPLE
    Set-AzClassicRole -ServiceName MyClassicService -Count 10 -Verbose -Force   

    VERBOSE: Service: MyClassicService
    VERBOSE: Current Role instance count: 8
    VERBOSE: Scaling role RunbookWorker.Cloud to 10
    #>
    
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName', 'Name')]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string[]]$Slot = 'Production',

        [parameter(ValueFromPipelineByPropertyName)]
        [string]$RoleName = "*",

        [parameter(ParameterSetName = 'count', Mandatory, Position = 1)]
        [Alias('InstanceCount')]
        [ValidateRange('Positive')]
        [int]$Count,

        [parameter()]
        [string]$ApiVersion = '2016-11-01',

        [parameter()]
        [switch]$Force
    )

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "Service: $service"
            if ($PSCmdlet.ParameterSetName -eq 'count') {
                foreach ($sl in $Slot) {
                    $serviceConfiguration = $null
                    $serviceConfiguration = Get-AzClassicServiceConfiguration -ServiceName $service -Slot $sl
                    $role = $null
                    $role = Get-AzClassicRole -ServiceName $service -Slot $sl | Where-Object 'RoleName' -Like $RoleName

                    $roleConfiguration = $null
                    $roleConfiguration = $serviceConfiguration.Role | Where-Object 'Name' -Like $RoleName

                    if ($roleConfiguration) {
                        Write-Verbose "Role $($role.Name) instance count: $($roleConfiguration.Instances.count)"
                        Write-Verbose "Scaling role $($role.Name) to $Count"
                        $roleConfiguration.Instances.count = $Count

                        $properties = $null
                        $properties = @{"deploymentLabel" = "$($role.Label)"; "configuration" = $serviceConfiguration.OuterXml }

                        if ($Force -or ($PSCmdlet.ShouldProcess("$($role.ServiceName)", "Scale Role"))) {
                            if ($Force -or ($PSCmdlet.ShouldContinue("Scale Role $($role.RoleName)", "Scale Role"))) {
                                Set-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/production" -ResourceName $role.ServiceName -ResourceGroupName $role.ResourceGroupName -ApiVersion $ApiVersion -Properties $properties -Force | Out-Null
                            }
                        }
                    }
                }
            }
        }
    }
}