function Get-AzClassicDeployment {
    <#
    .SYNOPSIS
    Return information about a PaaS service deployment
    
    .PARAMETER ServiceName
    The name of the Service to query for deployment details
    
    .PARAMETER Slot
    The deployment slot (Production or Staging) to query
    
    .PARAMETER ApiVersion
    Resource Provider Api Version to use.
    Default: 2015-10-01
    
    .PARAMETER Raw
    Returns the Raw configuration xml configuration (cscfg)
    
    .EXAMPLE
    Get-AzClassicDeployment -ServiceName MyClassicService

    ServiceName      : MyClassicService
    DeploymentId     : 948f665aa7cf4b44b839ca272019c8f7
    Status           : Running
    LastModifiedTime : 2019-12-14T06:12:34Z
    PublicIpAddress  : 192.168.0.1
    PublicPort       : 443
    DeploymentLabel  : Test Deployment
    #>
    
    [CmdletBinding()]
    [OutputType('AzClassicDeployment')]
    param (
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('ResourceName')]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string]$Slot = 'Production',

        [parameter()]
        [string]$ApiVersion = '2015-10-01',

        [parameter()]
        [switch]$Raw
    )

    process {
        foreach ($service in $ServiceName) {
            $serviceObject = $null
            Write-Verbose "Reading $service Cloud Service details"
            $services = Get-AzClassicService -ServiceName $service
            
            foreach ($serviceObject in $services) {
                foreach ($s in $Slot) {
                    Write-Verbose "Deployment Slot: $s"
                    $deployment = $null
                    Write-Verbose "Reading deploment details"
                    $deployment = Get-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/$($s.ToLower())" -ResourceName $serviceObject.Name -ResourceGroupName $serviceObject.ResourceGroupName -ApiVersion $ApiVersion -ErrorAction 'SilentlyContinue'
                    $role = $null
                    $role = Get-AzResource -ApiVersion $ApiVersion -ResourceType "Microsoft.ClassicCompute/domainNames/slots/$($s.ToLower())/roles" -ResourceName $serviceObject.ServiceName -ResourceGroupName $serviceObject.Name -ErrorAction 'SilentlyContinue'

                    if (! $deployment) { continue }

                    if ($Raw) {
                        Write-Verbose "Return RAW Cloud Service deployment configuration"
                        return $deployment
                    }

                    $outObj = $null
                    $outObj = $deployment | Select-Object -ExcludeProperty 'Properties' -Property *,
                    @{l = 'ServiceName'; e = { $serviceObject.ServiceName } },
                    @{l = 'ProvisioningState'; e = { $deployment.Properties.provisioningState } },
                    @{l = 'DeploymentLabel'; e = { $deployment.Properties.DeploymentLabel } },
                    @{l = 'Status'; e = { $deployment.Properties.status } },
                    @{l = 'LastModifiedTime'; e = { $deployment.Properties.lastModifiedTime } },
                    @{l = 'Uri'; e = { $deployment.Properties.uri } },
                    @{l = 'DeploymentName'; e = { $deployment.Properties.deploymentName } },
                    @{l = 'DeploymentId'; e = { $deployment.Properties.deploymentId } },
                    @{l = 'PublicIpAddress'; e = { $role[0].Properties.inputEndpoints.publicIpAddress } },
                    @{l = 'PublicPort'; e = { $role[0].Properties.inputEndpoints.publicPort } }

                    $outObj.PSObject.TypeNames.Insert(0, 'AzClassicDeployment')
                    $outObj
                }
            }
        }
    }
}