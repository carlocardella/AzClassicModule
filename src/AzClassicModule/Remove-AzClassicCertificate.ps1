function Remove-AzClassicCertificate {
    <#
    .SYNOPSIS
    Remove certificates from a PaaS Cloud Service

    .PARAMETER ServiceName
    The Cloud Service to remove certificates from

    .PARAMETER Thumbprint
    The thumbprint of the certificate to remove

    .PARAMETER ApiVersion
    API Version to use to call the Resource Provider action
    Default: 2016-11-01

    .PARAMETER Force
    Suppress configuration prompts

    .EXAMPLE
    Remove-AzClassicCertificate -ServiceName MyClassicService -Thumbprint C955EBF985D043B1F13159B74E5514843FD8E472 -Force

    True

    .EXAMPLE
    Get-AzClassicCertificate -ServiceName MyClassicService | Remove-AzClassicCertificate -Force

    True

    Removes all certificates from a Classic Service
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]$ServiceName,

        [parameter(ValueFromPipelineByPropertyName)]
        [string[]]$Thumbprint,

        [parameter()]
        [string]$ApiVersion = '2016-11-01',

        [parameter()]
        [switch]$Force
    )

    process {
        foreach ($service in $ServiceName) {
            Write-Verbose "Service: $service"
            $serviceObject = $null
            $serviceObject = Get-AzClassicService -ServiceName $service

            if ($Thumbprint.Count -lt 1) {
                $Thumbprint = Get-AzClassicCertificate -ServiceName $serviceObject.ServiceName | Select-Object -ExpandProperty 'Thumbprint'
            }

            $certificateName = @()
            $certificateName = Get-AzClassicCertificate -ServiceName $serviceObject.ServiceName | Where-Object 'Thumbprint' -In $Thumbprint | Select-Object -ExpandProperty 'CertificateName'

            if ($CertificateName) {
                foreach ($resourceName in $certificateName) {
                    Write-Verbose "Certificate $resourceName"
                    if ($Force -or ($PSCmdlet.ShouldProcess("$resourceName", "Remove certificate"))) {
                        if ($Force -or ($PSCmdlet.ShouldContinue("Remove certificate $resourceName", "Remove certificate"))) {
                            Remove-AzResource -ApiVersion $ApiVersion -ResourceType 'Microsoft.ClassicCompute/domainNames/serviceCertificates' -ResourceName "$($serviceObject.ServiceName)/$resourceName" -ResourceGroupName $serviceObject.ResourceGroupName -Force
                        }
                    }
                }
            }
        }
    }
}