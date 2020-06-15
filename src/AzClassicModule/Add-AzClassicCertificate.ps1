function Add-AzClassicCertificate {
    <#
    .SYNOPSIS
    Add a new certificate to a PaaS v1 Cloud Service

    .PARAMETER ServiceName
    Cloud Service to upload the certificate to

    .PARAMETER Certificate
    Certificate object (in memory) to upload

    .PARAMETER CertificateFile
    Certificate file path to upload

    .PARAMETER Password
    Private Key password
    
    .PARAMETER ApiVersion
    API version to use with the Resource Provider.
    Default: 2015-10-01

    .EXAMPLE
    Add-AzClassicCertificate -ServiceName MyCloudServiceeFile C:\LocalTemp\badcert\CN=prod-prod-keyvault1-auth-10-17.azure.com.pfx -Password $pwd -Verbose

    Name              : sha1-E3D34E1A8B1D354F89FB2CA147701945D6330805
    ResourceId        : /subscriptions/77fd10c6-6e20-4c82-a238-e38592f78346/resourceGroups/myResourceGroupMicrosoft.ClassicCompute/domainNames/MyCloudServMyCloudService9FB2CA147701945D6330805
    ResourceName      : MyCloudServiceFB2CA147701945D6330805
    ResourceType      : Microsoft.ClassicCompute/domainNames/serviceCertificates
    ResourceGroupName : myResourceGroupyResourceGroupyResourceGroup
    SubscriptionId    : 77fd10c6-6e20-4c82-a238-e38592f78346
    Properties        : @{data=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; thumbprint=E3D34E1A8B1D354F89FB2CA147701945D6330805; thumbprintAlgorithm=sha1}


    #>

    [CmdletBinding(DefaultParameterSetName = 'certificateFile')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]$ServiceName,

        [parameter(Mandatory, ParameterSetName = 'certificateObject')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [parameter(Mandatory, ParameterSetName = 'certificateFile')]
        [ValidateScript( { Test-Path $_ })]
        [string]$CertificateFile,

        [parameter()]
        [string]$ApiVersion = '2015-10-01',

        [parameter()]
        [securestring]$Password
    )

    begin {
        if ($PSCmdlet.ParameterSetName -eq 'certificateFile') {
            try {
                $CertificateFile = Resolve-Path -Path $CertificateFile
                $certificateFlags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
                $certificateFlags += [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet
                $certificateFlags += [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet
                $Certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($CertificateFile, $Password, $certificateFlags)
            }
            catch {
                Write-Error $_.Exception.Message
                return $false
            }
        }

        $resourceType = 'Microsoft.ClassicCompute/domainNames/serviceCertificates/'
    }

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "Service: $service"
            $serviceObject = $null
            $serviceObject = Get-AzClassicService -ServiceName $service

            New-AzResource -ResourceType $resourceType -ApiVersion $ApiVersion -Force -ResourceName "$($serviceObject.ServiceName)/sha1-$($Certificate.Thumbprint)" -ResourceGroupName $serviceObject.ResourceGroupName -Properties @{
                'Thumbprint'          = $Certificate.Thumbprint;
                'CertificateFormat'   = 'pfx';
                'ThumbprintAlgorithm' = 'sha1';
                'data'                = [System.Convert]::ToBase64String($Certificate.RawData);
                'password'            = (Unprotect-SecureString -SecureString $Password)
            }
        }
    }
}
