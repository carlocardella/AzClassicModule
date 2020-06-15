function Get-AzClassicRoleInstance {
    <#
    .SYNOPSIS
    Returns information about a Classic Service role instances (virtual machines)

    .PARAMETER ServiceName
    The Service name to query for role instances information

    .PARAMETER Slot
    The deployment slot to query

    .PARAMETER RoleName
    The Service Role name to query.
    By default all available Roles are returned

    .PARAMETER ApiVersion
    Resource Provider API version to use for this command.
    Default: 2015-10-01

    .EXAMPLE
    Get-AzClassicRoleInstance -ServiceName MyCloudService


    ResourceId                   : /subscriptions/41c042d2-35da-46fe-a65b-bd54485a5539/resourceGroups/MyCloudService/providers/Microsoft.ClassicCompute/domainNames/MyCloudService/slots/Production/roles/WebRole/roleInstances/WebRole_IN_0
    InstanceEndpoint             :
    InstanceErrorCode            :
    InstanceName                 : WebRole_IN_0
    InstanceSize                 : Standard_D4_v2
    InstanceStateDetails         :
    InstanceStatus               : ReadyRole
    InstancePowerStatus          : Started
    InstanceUpgradeDomain        : 0
    InstanceFaultDomain          : 0
    RoleName                     : WebRole
    DeploymentID                 : 8a20129cde644279b8dbd4ab64636f49
    DeploymentName               : 775b2fba884c4d15b5f0949503125e7e
    Label                        : test deployment
    IPAddress                    : 10.0.0.4
    PublicIPAddress              : {192.168.0.1}
    PublicIPName                 :
    PublicIPIdleTimeoutInMinutes :
    PublicIPDomainNameLabel      :
    PublicIPFqdns                :
    ServiceName                  : MyCloudService
    OperationDescription         :
    OperationId                  :
    OperationStatus              :
    DeploymentLocked             : False

    ResourceId                   : /subscriptions/26da2468-2f77-4993-9044-0576b49138a8/resourceGroups/MyCloudService/providers/Microsoft.ClassicCompute/domainNames/MyCloudService/slots/Production/roles/WebRole/roleInstances/WebRole_IN_1
    InstanceEndpoint             :
    InstanceErrorCode            :
    InstanceName                 : WebRole_IN_1
    InstanceSize                 : Standard_D4_v2
    InstanceStateDetails         :
    InstanceStatus               : ReadyRole
    InstancePowerStatus          : Started
    InstanceUpgradeDomain        : 1
    InstanceFaultDomain          : 1
    RoleName                     : InternalRole
    DeploymentID                 : 8a20129cde644279b8dbd4ab64636f49
    DeploymentName               : 775b2fba884c4d15b5f0949503125e7e
    Label                        : test deployment
    IPAddress                    : 10.0.0.5
    PublicIPAddress              : {192.168.0.1}
    PublicIPName                 :
    PublicIPIdleTimeoutInMinutes :
    PublicIPDomainNameLabel      :
    PublicIPFqdns                :
    ServiceName                  : MyCloudService
    OperationDescription         :
    OperationId                  :
    OperationStatus              :
    DeploymentLocked             : False

    [...]
    #>

    [CmdletBinding()]
    [OutputType('AzClassicRoleInstance')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName', 'Name')]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string[]]$Slot = 'Production',

        [parameter()]
        [string[]]$RoleName = "*",

        [parameter()]
        [string]$ApiVersion = '2015-10-01'
    )

    process {
        foreach ($service in $ServiceName) {
            $serviceObject = $null
            $serviceObject = Get-AzClassicService -ServiceName $service

            if ($serviceObject) {
                foreach ($sl in $Slot) {
                    $roles = $null
                    $roles = Get-AzClassicRole -ServiceName $serviceObject.ServiceName | Where-Object 'Name' -Like $RoleName

                    foreach ($rl in $roles) {
                        if ($rl.Name -like $RoleName) {
                            $roleObject = Get-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/$($sl.ToLower())/roles/$($rl.Name)/roleInstances" -ResourceName $serviceObject.ServiceName -ResourceGroupName $serviceObject.ResourceGroupName -ApiVersion $ApiVersion

                            if ($roleObject) {
                                foreach ($instance in $roleObject) {
                                    $instanceObject = $null
                                    $instanceObject = [pscustomobject]@{
                                        'RoleName'                     = $rl.Name;
                                        'InstanceName'                 = $instance.Name;
                                        'ResourceId'                   = $instance.ResourceId;
                                        'InstanceEndpoint'             = $null;
                                        'InstanceErrorCode'            = $null;
                                        'InstanceSize'                 = $instance.Properties.hardwareProfile.size;
                                        'InstanceStateDetails'         = $instance.Properties.instanceView.statusMessage;
                                        'InstanceStatus'               = $instance.Properties.instanceView.status;
                                        'InstancePowerStatus'          = $instance.Properties.instanceView.powerState;
                                        'InstanceUpgradeDomain'        = $instance.Properties.instanceView.updateDomain;
                                        'InstanceFaultDomain'          = $instance.Properties.instanceView.faultDomain;
                                        'DeploymentID'                 = $instance.Properties.hardwareProfile.deploymentId;
                                        'DeploymentName'               = $instance.Properties.hardwareProfile.deploymentName;
                                        'Label'                        = $instance.Properties.hardwareProfile.deploymentLabel;
                                        'IPAddress'                    = $instance.Properties.instanceView.privateIpAddress;
                                        'PublicIPAddress'              = $instance.Properties.instanceView.publicIpAddresses;
                                        'PublicIPName'                 = $null;
                                        'PublicIPIdleTimeoutInMinutes' = $null;
                                        'PublicIPDomainNameLabel'      = $null;
                                        'PublicIPFqdns'                = $null;
                                        'ServiceName'                  = $serviceObject.ServiceName;
                                        'OperationDescription'         = $null;
                                        'OperationId'                  = $null;
                                        'OperationStatus'              = $null;
                                        'DeploymentLocked'             = $instance.Properties.hardwareProfile.deploymentLocked;

                                    }

                                    $instanceObject.PSObject.TypeNames.Insert(0, 'AzClassicRoleInstance')
                                    $instanceObject
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}