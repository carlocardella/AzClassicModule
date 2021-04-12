function Set-AzClassicServiceConfiguration {
    <#
    .SYNOPSIS
    Updates one or more configuration values in a PaaS Cloud Service

    .PARAMETER ServiceName
    PaaS Cloud Service to update

    .PARAMETER RoleName
    Service Role within the PaaS Cloud Service to update

    .PARAMETER SettingName
    Setting to update

    .PARAMETER SettingValue
    New Setting value

    .PARAMETER SettingsList
    Array of HashTables containing the list of Settings to update
    E.g.: $SettingsList = @(
        @{
            'RoleName' = 'WebRole';
            'Name'     = 'EnableFeature';
            'Value'    = 'True'
        },
        @{
            'RoleName' = 'WebRole';
            'Name'     = 'TimeoutSeconts';
            'Value'    = '5'
        }
    )

    .PARAMETER Slot
    Slot (Production or Staging) containing the configuration to update
    Default value: Production

    .PARAMETER CertificateName
    The certificate setting name to update

    .PARAMETER CertificateThumbprint
    New thumbprint for the certificate in CertificateName

    .PARAMETER Certificatelist
    Array of HashTables containing the list of certificates to update
    E.g.: $certificates = @(
        @{
            'RoleName'   = 'WebRole';
            'Name'       = 'EncryptionCertificate';
            'Thumbprint' = '1515261298C0E7E71B8283B616A37F1CF9EFDA08'
        },
        @{
            'RoleName'   = 'WebRole';
            'Name'       = 'SslCertificate';
            'Thumbprint' = 'B8C8EB9D4E92B4ED72BCAE9C35A93D3EA9DF2127'
        }
    )

    .PARAMETER ApiVersion
    ApiVersion to use with the ResourceProvider calls

    .PARAMETER Force
    Suppress update security prompts

    .EXAMPLE
    Set-AzClassicServiceConfiguration -ServiceName MyCloudService -RoleName WorkerRole -SettingName RoleExecutionMode -SettingValue Drain -Force

    .EXAMPLE
    Set-AzClassicServiceConfiguration -ServiceName MyCloudService -Settings @(@{'RoleName'='WebRole';'SettingName'='RetryCound'; 'SettingValue'='3'}, @{'RoleName'='WebRole'; 'SettingName'='RetryTimeoutSeconts'; 'SettingValue'='5'})

    .EXAMPLE
    Set-AzClassicServiceConfiguration -ServiceName MyCloudService -RoleName WebRole -CertificateName SslCertificate -CertificateThumbprint 40F38AE0CA9F599EB85620417FBD8B015BE9119C -Verbose -Force

    .EXAMPLE
    Set-AzClassicServiceConfiguration -ServiceName MyCloudService -CertificateList @{@{'RoleName'='WebRole'; 'Name'='SslCertificate'; 'Thumbprint'='40F38AE0CA9F599EB85620417FBD8B015BE9119C'}, @{'RoleName'='InternalRole'; 'Name'='SslCertificate'; 'Thumbprint'='40F38AE0CA9F599EB85620417FBD8B015BE9119C'}) -Verbose -Force
    #>
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess, DefaultParameterSetName = 'servicename')]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [string]$ServiceName,

        [parameter(ParameterSetName = 'servicename', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$RoleName = "*",

        [parameter(Mandatory, ParameterSetName = 'servicename')]
        [ValidateNotNullOrEmpty()]
        [string]$SettingName,

        [parameter(Mandatory, ParameterSetName = 'servicename')]
        [string]$SettingValue,

        [parameter(ParameterSetName = 'ht')]
        [ValidateScript( {
                $_ | ForEach-Object {
                    if (($_.Keys -contains 'RoleName') -and ($_.Keys -contains 'Name') -and ($_.Keys -contains 'Value')) {
                        $true
                    }
                    else {
                        throw "Parameter format is invalid."
                    }
                }
            })
        ]
        [hashtable[]]$SettingsList,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Production', 'Staging')]
        [string]$Slot = 'Production',

        [parameter(ParameterSetName = 'certificate')]
        [string]$CertificateName,

        [parameter(ParameterSetName = 'certificate')]
        [ValidateScript( {
                if ($_ | Select-String -Pattern '\A\b[0-9a-fA-F]{40}\b\Z') {
                    $true
                }
                else {
                    throw "Invalid Thumbprint"
                }
            }
        )]
        [string]$CertificateThumbprint,

        [parameter(ParameterSetName = 'ht')]
        [ValidateScript( {
                $_ | ForEach-Object {
                    if (($_.Keys -contains 'RoleName') -and ($_.Keys -contains 'Name') -and ($_.Keys -contains 'Thumbprint')) {
                        $true
                    }
                    else {
                        throw "Parameter format is invalid."
                    }
                }
            })
        ]
        [hashtable[]]$CertificateList,

        [parameter()]
        [string]$ApiVersion = '2015-10-01',

        [parameter()]
        [switch]$Force
    )

    begin {
        $deploymentResourceType = "Microsoft.ClassicCompute/domainNames/deploymentSlots/$($Slot.ToLower())"

        $subscriptionId = (Get-AzContext).Subscription.Id

        if ($PSCmdlet.ParameterSetName -eq 'servicename') {
            $settingsHT = @{ 'RoleName' = $RoleName; 'Name' = $SettingName; 'Value' = $SettingValue }
            $SettingsList = $settingsHT
            Write-Verbose ($SettingsList | Out-String)
        }

        if ($PSCmdlet.ParameterSetName -eq 'certificate') {
            $certificatesHT = @{ 'RoleName' = $RoleName; 'Name' = $CertificateName; 'Thumbprint' = $CertificateThumbprint }
            $Certificatelist = $certificatesHT
            Write-Verbose ($CertificateList | Out-String)
        }
    }

    process {
        try {
            $resource = $null
            $resource = Get-AzResource -ResourceType 'Microsoft.ClassicCompute/domainNames' -Name $ServiceName
            if ($resource) {
                Write-Verbose "Retrieving current service configuration"
                $deployment = Get-AzResource -ResourceType $deploymentResourceType -ResourceName $resource.Name -ResourceGroupName $resource.ResourceGroupName -ApiVersion $ApiVersion
            }
            else {
                Write-Verbose "Service $ServiceName not found"
            }
        }
        catch {
            throw $_.Exception
        }

        $configuration = $null
        [xml]$configuration = $deployment.Properties.configuration
        $roles = $null
        $roles = $configuration.ServiceConfiguration.Role | Where-Object Name -Like $RoleName

        foreach ($role in $roles) {
            foreach ($cert in $CertificateList) {
                if (($cert.RoleName -eq '*') -or ($role.Name -eq $cert.RoleName)) {
                    try {
                        $currentCert = $null
                        $currentCert = $role.Certificates.Certificate.Where( { $_.name -eq $cert.Name })[0]
                        Write-Verbose -Message "Current certificate: $($currentCert.Name), thumbprint: $($currentCert.thumbprint))"
                        $currentCert.thumbprint = $cert.Thumbprint
                    }
                    catch {
                        Write-Error "Could not find certificate $($cert.Name) in role $($role.name)"
                    }
                }
            }

            foreach ($set in $SettingsList) {
                if (($set.RoleName -eq '*') -or ($role.Name -eq $set.RoleName)) {
                    try {
                        $currentSetting = $null
                        $currentSetting = $role.ConfigurationSettings.Setting.Where( { $_.Name -eq $set.Name })[0]
                        Write-Verbose -Message "Current setting: $($role.name), Setting: $($currentSetting.name), Value: $($currentSetting.value)"
                        $currentSetting.Value = $set.Value
                    }
                    catch {
                        Write-Error "Could not find setting $($set.Name) in role $($role.name)"
                    }
                }
            }
        }

        try {
            $properties = $null
            $properties = @{"deploymentLabel" = "$($deployment.Properties.DeploymentLabel)"; "configuration" = $configuration.OuterXml }

            if ($Force -or ($PSCmdlet.ShouldProcess("Service $($resource.Name), Subscription $SubscriptionId", "Set service configuration"))) {
                if ($Force -or ($PSCmdlet.ShouldContinue("Update Service $($resource.Name), Subscription $SubscriptionId", "Set service configuration?"))) {
                    Write-Verbose -Message "Updating $($resource.Name), Subscription $SubscriptionId"

                    try {
                        Set-AzResource -ResourceType $deploymentResourceType -ResourceName $resource.Name -ResourceGroupName $resource.ResourceGroupName -ApiVersion $ApiVersion -Properties $properties -Force | Out-Null
                    }
                    catch {
                        $_.Exception.Message
                    }
                }
            }
        }
        catch {
            Write-Error $_.Exception
        }
    }
}
