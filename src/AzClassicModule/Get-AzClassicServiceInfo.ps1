function Get-AzClassicServiceInfo {
    <#
    .SYNOPSIS
        Lists Production deployment Cloud Service basic properties from the current Azure Subscription
        Properties returned: ServiceName, Location, Label, Status, InstanceCount.

    .EXAMPLE
        Get-AzClassicServiceInfo -ServiceName MyCloudService

        ServiceName    : MyCloudService
        Slot           : Production
        Location       : centralus
        Label          : 02282019175704-9DF21705877A41D49D3D7792A9891C780WebSvc-WebSvc
        Status         : Running
        DeploymentName : 1dc4c1b7e75046a7b42af7cc8838012e

        This command shows details about the available services in the subscription passed at the command line
    #>

    [CmdletBinding(DefaultParameterSetName = 'SubscriptionName')]
    [OutputType('Microsoft.Azure.AzureServiceInfo')]
    param(
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 1)]
        [Alias('ResourceName', 'Name')]
        [string[]]$ServiceName,

        [parameter()]
        ## Reports the Staging slot in addition to the Production one
        [switch]$IncludeStagingSlot
    )

    process {
        if ([string]::IsNullOrWhiteSpace($ServiceName)) {
            $ServiceName = Get-AzResource -ResourceType 'Microsoft.ClassicCompute/domainNames' | Select-Object -ExpandProperty 'Name'
        }

        foreach ($service in $ServiceName) {

            $outObj = $null
            $resource = $null
            $resource = Get-AzResource -Name $service -ResourceType 'Microsoft.ClassicCompute/domainNames'
            $location = Get-AzLocation | Where-Object 'Location' -eq $resource.Location | Select-Object -ExpandProperty 'DisplayName'

            $outObj = Get-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/production" `
                -Name $resource.Name -ResourceGroupName $resource.ResourceGroupName `
                -ErrorAction 'SilentlyContinue' -PipelineVariable 'deployment' -ApiVersion '2018-06-01' |
            Select-Object @{l = 'ServiceName'; e = { $service } }, `
            @{l = 'Slot'; e = { 'Production' } }, `
            @{l = 'Location'; e = { $location } }, `
            @{l = 'Label'; e = { $deployment.Properties.deploymentLabel } }, `
            @{l = 'Status'; e = { $deployment.Properties.Status } }, `
            @{l = 'DeploymentName'; e = { $deployment.Properties.DeploymentName } }#, `
            # @{l = 'InstanceCount'; e = {
            #         (Get-AzResource -ResourceType 'Microsoft.ClassicCompute/domainNames/deploymentslots/production/roles' `
            #                 -Name $resource.Name -ResourceGroupName $resource.ResourceGroupName -ApiVersion '2018-06-01').Sku.Capacity}
            # }

            if ($outObj) {
                $outObj.PSObject.TypeNames.Insert(0, 'Microsoft.Azure.AzureServiceInfo')
                $outObj
            }

            if ($IncludeStagingSlot) {
                $outObj = $null

                $outObj = Get-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/staging" `
                    -Name $resource.Name -ResourceGroupName $resource.ResourceGroupName `
                    -ErrorAction 'SilentlyContinue' -PipelineVariable 'deployment' -ApiVersion '2018-06-01' |
                Select-Object @{l = 'ServiceName'; e = { $service } }, `
                @{l = 'Slot'; e = { 'Staging' } }, `
                @{l = 'Location'; e = { $location } }, `
                @{l = 'Label'; e = { $deployment.Properties.deploymentLabel } }, `
                @{l = 'Status'; e = { $deployment.Properties.Status } }, `
                @{l = 'DeploymentName'; e = { $deployment.Properties.DeploymentName } }#, `
                # @{l = 'InstanceCount'; e = {
                #         (Get-AzResource -ResourceType 'Microsoft.ClassicCompute/domainNames/deploymentslots/production/roles' `
                #                 -Name $resource.Name -ResourceGroupName $resource.ResourceGroupName -ApiVersion '2018-06-01').Sku.Capacity}
                # }

                if ($outObj) {
                    $outObj.PSObject.TypeNames.Insert(0, 'Microsoft.Azure.AzureServiceInfo')
                    $outObj
                }
            }
        }
    }
}
