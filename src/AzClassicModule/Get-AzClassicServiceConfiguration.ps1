
function Get-AzClassicServiceConfiguration {
    <#
    .SYNOPSIS
        Retrieve a PaaS Service configuration; it can return some specific setting value(s) or the entire cscfg

    .PARAMETER ServiceName
        The cloud service to query to return the configuration setting or certificates list

    .PARAMETER RoleName
        Service role to query to return the requested setting or certificates

    .PARAMETER SettingName
        Setting to return from the service configuration file (cscfg)

    .PARAMETER Slot
        Deployment slot to return the setting or certificate from 

    .PARAMETER Certificates
        Returns the Certificates listed in the Certificates section of the service configuration file (cscfg)

    .PARAMETER RawXml
        Returns the service configuration as XML string

    .PARAMETER ApiVersion
        ApiVersion to use with the ARM call.
        Default: 2015-10-01

    .OUTPUTS
        PSCustomObject
        System.Xml.XmlElement#http://schemas.microsoft.com/ServiceHosting/2008/10/ServiceConfiguration#ServiceConfiguration

    .EXAMPLE
    	Get-AzClassicServiceConfiguration -ServiceName MyCloudService -ResourceGroupName MyCloudService -SettingName SettingOne, OtherSetting | Format-Table -AutoSize

        ServiceName     SettingName     Value
    	-----------     -----------     -----
    	MyCloudService  SettingOne      value1
    	MyCloudService  OtherSetting    value2

    .EXAMPLE
    	Get-AzClassicServiceConfiguration MyCloudService -Certificates -RoleName ServiceRole | Format-Table -AutoSize

    	ServiceName     RoleName        CertificateName                  Thumbprint                               ThumbprintAlgorithm
    	-----------     --------        ---------------                  ----------                               -------------------
    	MyCloudService  ServiceRole     SslCertificate                   9C87CC330D3513F6B0F9AE6EAEBC8EBDF2117A3A sha2
    	MyCloudService  ServiceRole     EncryptionCertificate            85D2F9BA69D0AC653164C5DD6A0AA8F15C36D259 sha2
    	MyCloudService  ServiceRole     SpnAuthCertificate               7A321CD76300A864378DABF5FF5DAB456A22EBDA sha2
    #>
    [CmdletBinding(DefaultParameterSetName = 'config')]
    [OutputType('PSCustomObject')]
    [OutputType('System.Xml.XmlElement#http://schemas.microsoft.com/ServiceHosting/2008/10/ServiceConfiguration#ServiceConfiguration')]
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]$ServiceName,

        [parameter()]
        [string]$RoleName,

        [parameter(ParameterSetName = 'config')]
        [string[]]$SettingName,

        [parameter()]
        [ValidateSet('Production', 'Staging')]
        [string]$Slot = 'Production',

        [parameter(ParameterSetName = 'certs')]
        [switch]$Certificates,

        [parameter(ParameterSetName = 'raw')]
        [switch]$RawXml,

        [parameter()]
        [string]$ApiVersion = '2015-10-01'
    )

    process {
        foreach ($service in $ServiceName) {
            try {
                Write-Verbose $service
                $config = $null
                $resource = $null
                $resource = Get-AzResource -ResourceType 'Microsoft.ClassicCompute/domainNames' -Name $service
                if ($null -ne $resource) {
                    $config = Get-AzResource -ResourceType "Microsoft.ClassicCompute/domainNames/deploymentSlots/$($Slot.ToLower())" -ResourceName $resource.Name -ResourceGroupName $resource.ResourceGroupName -ApiVersion $ApiVersion

                    $xml = $null
                    [xml]$xml = $config.Properties.configuration

                    $roles = $null
                    if (![string]::IsNullOrWhiteSpace($SettingName) -or $Certificates) {
                        if (![string]::IsNullOrWhiteSpace($RoleName)) {
                            $roles = $xml.ServiceConfiguration.Role | Where-Object Name -eq $RoleName
                        }
                        else {
                            $roles = $xml.ServiceConfiguration.Role
                        }

                        if ($null -ne $roles) {
                            foreach ($role in $roles) {
                                if ($Certificates) {
                                    $certificate = $null
                                    foreach ($certificate in $role.Certificates.Certificate) {
                                        [PSCustomObject]@{
                                            'ServiceName'         = $service;
                                            'RoleName'            = $role.Name;
                                            'CertificateName'     = $certificate.name;
                                            'Thumbprint'          = $certificate.thumbprint;
                                            'ThumbprintAlgorithm' = $certificate.thumbprintAlgorithm
                                        }
                                    }
                                }

                                if (![string]::IsNullOrWhiteSpace($SettingName)) {
                                    $Role.ConfigurationSettings.Setting.Where( { $_.Name -like $SettingName }) | ForEach-Object {
                                        Write-Verbose $_.Name
                                        [PSCustomObject]@{
                                            'ServiceName' = $service;
                                            'RoleName'    = $Role.Name;
                                            'SettingName' = $_.Name;
                                            'Value'       = $_.Value
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        if ($RawXml) {
                            $xml.ServiceConfiguration.OuterXml
                        }
                        else {
                            $xml.ServiceConfiguration
                        }
                    }
                }
            }
            catch {
                Write-Error $_.Exception
            }
        }
    }
}