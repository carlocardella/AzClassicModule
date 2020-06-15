function Get-AzClassicRoleInstancePowerStatus {
    <#
    .SYNOPSIS
    Gets role instance power status and details from the given PaaS service

    .DESCRIPTION
    Gets role instance power status and details from the given PaaS service

    .PARAMETER ServiceName
    Service to query for instance status. Accepts wildcards

    .PARAMETER Slot
    Slot to query. Default value is 'Production'

    .PARAMETER ApiVersion
    API version to use for the ARM call.
    Default: 2018-06-01

    .EXAMPLE
    Get-AzClassicRoleInstancePowerStatus -ServiceName MyCloudService | Format-Table -AutoSize

    ServiceName     InstanceName        InstanceStatus PowerState UpdateDomain FaultDomain StatusMessage
    -----------     ------------        -------------- ---------- ------------ ----------- -------------
    MyCloudService  RoleWeb_IN_0        ReadyRole      Started               0           0
    MyCloudService  RoleWeb_IN_1        ReadyRole      Started               1           1
    MyCloudService  RoleWeb_IN_2        ReadyRole      Started               2           0
    MyCloudService  RoleWeb_IN_3        ReadyRole      Started               3           1
    MyCloudService  RoleWeb_IN_4        ReadyRole      Started               4           0
    MyCloudService  RoleInternal_IN_0   ReadyRole      Started               0           0
    MyCloudService  RoleInternal_IN_1   ReadyRole      Started               1           1
    MyCloudService  RoleInternal_IN_2   ReadyRole      Started               2           0

    This command returns power information about all role instances in MyService
    #>
    [OutputType('AzClassicRoleInstancePowerStatus')]
    [CmdletBinding()]
    param(
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 1)]
        [Alias('ResourceName', 'Name')]
        [string[]]$ServiceName,

        [parameter()]
        [ValidateSet('Production', 'Staging')]
        [string]$Slot = 'Production',

        [parameter()]
        [string]$ApiVersion = '2018-06-01'
    )

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "$service"
            $resources = $null
            $resources = Get-AzClassicService -ServiceName $service

            foreach ($resource in $resources) {
                $roles = Get-AzClassicRole -ServiceName $resource.Name -Slot $Slot | Select-Object -ExpandProperty 'Name'

                foreach ($role in $roles) {
                    $instances = $null
                    $instances = Get-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/$Slot/roles/$role/roleInstances" -ResourceName $resource.Name -ResourceGroupName $resource.ResourceGroupName -ApiVersion $ApiVersion

                    foreach ($instance in $instances) {
                        $outObj = [PSCustomObject]@{
                            ServiceName    = $resource.Name;
                            InstanceName   = $instance.Name;
                            InstanceStatus = $instance.Properties.instanceView.status;
                            PowerState     = $instance.Properties.instanceView.PowerState;
                            UpdateDomain   = $instance.Properties.instanceView.updateDomain;
                            FaultDomain    = $instance.Properties.instanceView.faultDomain;
                            StatusMessage  = $instance.Properties.instanceView.statusMessage
                        }

                        $outObj.PSObject.TypeNames.Insert(0, 'AzClassicRoleInstancePowerStatus')
                        $outObj
                    }
                }
            }
        }
    }
}