function Get-AzClassicRole {
    <#
    .SYNOPSIS
    Returns information about a Classic (PaaS) Cloud Service Role

    .PARAMETER ServiceName
    Service to return information from

    .PARAMETER Slot
    The deployment slot (Production or Staging) to query

    .PARAMETER ApiVersion
    Resource Provider Api Version to use.
    Default: 2016-11-01

    .PARAMETER RoleName
    If specified, returns informaion about this Cloud Service Role but not others (in case the Cloud Service contains multiple roles)

    .EXAMPLE
    Get-AzClassicrole -ServiceName MyCloudService

    ServiceName     : MyCloudService
    Name            : WebRole
    InstanceCount   : 5
    Label           : Test Deployment
    DeploymentId    : 948f665aa7cf4b44b839ca272019c8f7
    OsVersion       : WA-GUEST-OS-5.37_201911-01
    PublicIpAddress : 192.168.0.1
    PublicPort      : 443

    ServiceName     : MyCloudService
    Name            : InternalRole
    InstanceCount   : 3
    Label           : Test Deployment
    DeploymentId    : 948f665aa7cf4b44b839ca272019c8f7
    OsVersion       : WA-GUEST-OS-5.37_201911-01
    PublicIpAddress : 192.168.0.2
    PublicPort      : 444
    #>
    [CmdletBinding()]
    [OutputType("AzClassicRole")]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1)]
        [Alias('ResourceName', 'Name')]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string[]]$Slot = 'Production',

        [parameter()]
        [string]$ApiVersion = '2016-11-01',

        [parameter()]
        [string[]]$RoleName = "*"
    )

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "Service: $service"
            $serviceObject = $null
            $serviceObject = Get-AzClassicService -ServiceName $service

            if ($serviceObject) {
                foreach ($s in $Slot) {
                    Write-Verbose "Slot: $s"
                    $outObj = [pscustomobject]@{ }
                    $roles = Get-AzResource -ApiVersion $ApiVersion -ResourceType "Microsoft.ClassicCompute/domainNames/slots/$($s.ToLower())/roles" -ResourceName $serviceObject.ServiceName -ResourceGroupName $serviceObject.ResourceGroupName -ErrorAction 'SilentlyContinue'

                    foreach ($outObj in $roles) {
                        Write-Verbose "Role: $($outObj.Name)"
                        $instances = $null
                        $instances = Get-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/$($s.ToLower())/roles/$($outObj.Name)/roleInstances" -ResourceName $serviceObject.ServiceName -ResourceGroupName $serviceObject.ResourceGroupName -ApiVersion $apiVersion

                        $outObj = $outObj | Select-Object `
                        @{l = 'ServiceName'; e = { $serviceObject.ServiceName } },
                        @{l = 'Name'; e = { $_.ResourceName } },
                        ResourceGroupName,
                        ResourceId,
                        @{l = 'OSVersion'; e = { $_.Properties.osVersion } },
                        Sku,
                        @{l = 'Endpoints'; e = { $_.Properties.inputEndpoints } },
                        @{l = 'Hardware'; e = { $_.Properties.hardwareProfile } },
                        @{l = 'InstanceCount'; e = { $instances.Count } }

                        $outObj.PSObject.TypeNames.Insert(0, 'AzClassicRole')

                        $outObj | Where-Object { $_.Name -like $RoleName }
                    }
                }
            }
        }
    }
}