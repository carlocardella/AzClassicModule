function Set-AzClassicDeployment {
    <#
    .SYNOPSIS
    Set the status of a classic Cloud Service Deployment (Running or Suspended in RDFE terminology)
    
    .PARAMETER ServiceName
    Cloud Service whose deployment to start or stop
    
    .PARAMETER ResourceGroupName
    Resource Group containing the Cloud Service
    
    .PARAMETER Slot
    The Deployment Slot to start or stop
    
    .PARAMETER Action
    Action to perform on the Deployment Slot (start or stop)
    
    .PARAMETER ApiVersion
    API version to use to execute the command
    Default: 2015-10-01
    
    .PARAMETER Force
    Suppresses the confirmation prompt
    
    .EXAMPLE
    Set-AzClassicDeployment -ServiceName MyClassicService -Action Start -Verbose -Force
    VERBOSE: Start MyClassicService Production deployment
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName')]
        [string]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string]$Slot = 'Production',

        [parameter(Mandatory)]
        [ValidateSet('Stop', 'Start')]
        [string]$Action,

        [parameter()]
        [string]$ApiVersion = '2015-10-01',

        [parameter()]
        [switch]$Force
    )

    process {
        $resourceGroupName = $null
        $resourceGroupName = Get-AzClassicService -ServiceName $ServiceName | Select-Object -ExpandProperty 'ResourceGroupName'

        if ($resourceGroupName) {
            if ($Force -or ($PSCmdlet.ShouldProcess("$ServiceName", "$Action"))) {
                if ($Force -or ($PSCmdlet.ShouldContinue("Change deployment state?", "Change deployment state"))) {
                    $resourceType = "Microsoft.ClassicCompute/domainNames/slots/$Slot"
                    Write-Verbose "$Action $ServiceName $Slot deployment"
                    Invoke-AzResourceAction -Action $Action -ResourceName $ServiceName -ResourceType $resourceType -ResourceGroupName $resourceGroupName -ApiVersion $ApiVersion -Force
                }
            }
        }
    }
}