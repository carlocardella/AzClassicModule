function Reset-AzClassicRoleInstance {
    <#
    .SYNOPSIS
    Resets the role instances of a given Azure Cloud Service or all the Cloud Services hosted in a given subscription
    
    .PARAMETER ServiceName
    The Cloud Service whose instances to reset
    
    .PARAMETER Slot
    Deploment Slot to reset
    
    .PARAMETER RoleName
    Instance Role to reset
    
    .PARAMETER InstanceName
    InstanceName to reset
    
    .PARAMETER Action
    Action to perform on the selected Role Instsance(s).
    Available Options: Restart, Reimage, Rebuild
    Default: Restart
    
    .PARAMETER ApiVersion
    API version to use for this command
    Default: 2016-11-01
    
    .PARAMETER Force
    Suppresses action confirmation prompt
    
    .EXAMPLE
    Reset-AzClassicRoleInstance -ServiceName MyClassicService -InstanceName ServiceRole_IN_0 -Action Reimage -Force

    Reimages the names Cloud Service Instnce

    .EXAMPLE
    Reset-AzClassicRoleInstance -ServiceName MyClassicService -RoleName ServiceRole -Action Restart -Force

    Restarts all instances in the passed Cloud Service Role

    .NOTES
    The RDFE equivalents for these actions are documented here:
    - Reboot Role Instance: https://docs.microsoft.com/en-us/previous-versions/azure/reference/gg441298(v=azure.100)?redirectedfrom=MSDN
        The Reboot Role Instance asynchronous operation requests a reboot of a role instance that is running in a deployment.

    - Reimage Role Instance: https://docs.microsoft.com/en-us/previous-versions/azure/reference/gg441292(v=azure.100)
        The Reimage Role Instance asynchronous operation reinstalls the operating system on instances of web roles or worker roles.
    
    - Rebuild Role Instance: https://docs.microsoft.com/en-us/previous-versions/azure/reference/dn627518(v=azure.100)
        The Rebuild Role Instance asynchronous operation reinstalls the operating system on instances of web roles or worker roles 
        and initializes the storage resources that are used by them. 
        If you do not want to initialize storage resources, you can use Reimage Role Instance.
    
    #>
    
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'role')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName', 'Name')]
        [string]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string]$Slot = 'Production',

        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'role')]
        [string]$RoleName = "*",

        [parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'instance')]
        [string[]]$InstanceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Restart', 'Reimage', 'Rebuild')]
        [string]$Action = 'Restart',

        [parameter()]
        [string]$ApiVersion = '2016-11-01',

        [parameter()]
        [switch]$Force
    )

    begin {
        $instanceObject = $null
        if ($PSCmdlet.ParameterSetName -eq 'role') { 
            $instanceObject = Get-AzClassicRoleInstance -ServiceName $ServiceName -Slot $Slot | Where-Object 'RoleName' -Like $RoleName
        }
        if ($PSCmdlet.ParameterSetName -eq 'instance') {
            $instanceObject = Get-AzClassicRoleInstance -ServiceName $ServiceName -Slot $Slot | Where-Object 'InstanceName' -In $InstanceName
        }

        if (! $instanceObject) { return $false }
    }

    process {
        foreach ($instance in $instanceObject) {
            if ($Force -or ($PSCmdlet.ShouldProcess("$($instance.Name) on Service $ServiceName", "$Action"))) {
                if ($Force -or ($PSCmdlet.ShouldContinue("$Action role instance $($instance.Name) on Service $ServiceName?", "$Action role instance"))) {
                    Write-Verbose "$($instance.InstanceName)"
                    Invoke-AzResourceAction -Action $Action -ResourceId $instance.ResourceId -ApiVersion $ApiVersion -Force
                }
            }
        }
    }
}