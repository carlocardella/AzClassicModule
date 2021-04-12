function Get-AzClassicCertificate {
    <#
    .SYNOPSIS
        Retrieves the list of certificates available to a PaaS Azure Cloud Service

    .PARAMETER ServiceName
        The Cloud Service Name to query for certificates

    .PARAMETER ApiVersion
        ApiVersion to use to retrieve the certificate details.
        Default: 2015-10-01

    .EXAMPLE
        Get-AzClassicCertificate -ServiceName MyClassicService | Select-Object -First 1

        Thumbprint                               Subject                                  Expires
        ----------                               -------                                  -------
        0F7AD5E20B44B2659B18095CAA7306F011A01EEC CN=*.myservice.azure.com     3/22/2018 11:03:18 AM

    .EXAMPLE
        Get-AzClassicCertificate -ServiceName MyClassicService | Select-Object -First 1  | Format-List

        ResourceName      : sha1-0F7AD5E20B44B2659B18095CAA7306F011A01EEC
        ResourceGroupName : MyClassicService
        ResourceType      : Microsoft.ClassicCompute/domainNames/serviceCertificates
        ResourceId        : /subscriptions/10c530cd-47da-4333-990b-476db275cd8e/resourceGroups/MyClassicService/providers/Microsoft.ClassicCompute/domainNames/MyClassicService/serviceCertificates/sha1-0F7AD5E20B44B2659B18095CAA7306F011A01EEC
        Thumbprint        : 0F7AD5E20B44B2659B18095CAA7306F011A01EEC
        Algorithm         : sha1
        Data              : MIIGTzCCBDegAwIBAgITWgADqiqcSOLKHZIQ4QABAAOqKjANBgkqhkiG9w0BAQsFADCBizELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEVMBMGA1UECxMMTWlj
                            cm9zb2Z0IElUMR4wHAYDVQQDExVNaWNyb3NvZnQgSVQgU1NMIFNIQTIwHhcNMTYwNjIyMTgwMzE4WhcNMTgwMzIyMTgwMzE4WjAsMSowKAYDVQQDDCEqLmNvbnRhaW5lcnMuYXp1cmUtYXV0b21hdGlvbi5uZXQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
                            AQCIfdzCzvETCTq5C1pLjfFKlojxGLsY0LQ/6D1kS27bloAKqPB8Mx3DT1KFublurKxNBkdBG/w8v3AXUvj7UMn7nI6ykQht8ejtS3waN5NiE+6y3OY3+gVhUpwgbD5c2Z4tZq6FDmDom2HjRwuxO8xOzCmAyevG2wc9UEozl87AX161JdB4iN6+0zueERbPlw3FS3lL
                            Fy1Tv+VgvJCWkQyn+0KPnkUiVWMTwRrwyMbod43+ECmRwvZNYqeBpXy8vpUyqKPkx0JFDuH3eskDh+2kirPiCEaIOUkW3Tb5g+NMOGOTfRfSNSaBeUFnwd7Sp1Z+nWIG0iXhYmmoii69JQpjAgMBAAGjggIIMIICBDAdBgNVHQ4EFgQUY/XQmuyEl1vLHdXVMf4M8W5B
                            nHswCwYDVR0PBAQDAgSwMB8GA1UdIwQYMBaAFFGvJCac9GgiV4AmKztGYhV7HsylMH0GA1UdHwR2MHQwcqBwoG6GNmh0dHA6Ly9tc2NybC5taWNyb3NvZnQuY29tL3BraS9tc2NvcnAvY3JsL21zaXR3d3cyLmNybIY0aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3Br
                            aS9tc2NvcnAvY3JsL21zaXR3d3cyLmNybDBwBggrBgEFBQcBAQRkMGIwPAYIKwYBBQUHMAKGMGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvbXNjb3JwL21zaXR3d3cyLmNydDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AubXNvY3NwLmNvbTAdBgNVHSUEFjAU
                            BggrBgEFBQcDAQYIKwYBBQUHAwIwTgYDVR0gBEcwRTBDBgkrBgEEAYI3KgEwNjA0BggrBgEFBQcCARYoaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9tc2NvcnAvY3BzADAnBgkrBgEEAYI3FQoEGjAYMAoGCCsGAQUFBwMBMAoGCCsGAQUFBwMCMCwGA1UdEQQl
                            MCOCISouY29udGFpbmVycy5henVyZS1hdXRvbWF0aW9uLm5ldDANBgkqhkiG9w0BAQsFAAOCAgEAZmCluXcDsXK3s5OQTq1covzZ2axKCXtjOkocZcB5Veu233+In83SCpDah/75MXYYKm1OSAZ7syNUiefNUTMnyOPV9aVBxLe9QJYWNnG/+NqsrwWgv1yuCHaz07gh
                            GbquZEd5SQj4IBWD4P6RQsuD1FRwO6NT3gQMBg5c0sMkPxyXCNvIOXBxeY+9jLMKzHA41pfEpT4nHnUl9CLvh42+ysOaBpNTQ/FaLCcPfntu7/h3zP7xIqqSI03XEnrLVps6D2cB/b5BgobpAvUC1Aa2LNrxU6tFBT8vD1B+s0+LFFmTsHwEFpO4XF6LDd3ivbFeeFTp
                            +KoqjHs+o6W3eRjjDUiC8hbpTFLdxLc+nuXTz3R/J4j7pnjqOloxMx4KyUO2XBL1hdQ/Rd1v4dzTxovEq0084Y68Xdv67+bg60ESKUdI3pgDEGlJCQFIq92db8gnaKbiTqGk6IT+j9/N2ZQ/6JikqsCbAlUZd1wa9JZdjispw+ZtVrUyyHzAwEuW9izewb02fxKoab8l
                            Du762y7TTwUcLREd+txrrwBxSatJuyTsUeJiQ2Q6leJAIiXFhTXM2yxiQZZg1RxLdu2T3An8EqveGCBNQXPZBZ4mkzYPN736lTYL/BiNYOfSowh4/TBkd3quphe7UgHamEw9N/GNp23bGl3zuLUr0lyk1NuiljI=
        Subject           : CN=*.myservice.azure.com
        Expires           : 3/22/2018 11:03:18 AM
    #>

    [OutputType('AzClassicCertificate')]
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('ResourceName', 'Name')]
        [string[]]$ServiceName,

        [parameter()]
        [string]$ApiVersion = '2015-10-01'
    )

    begin {
        $resourceType = 'Microsoft.ClassicCompute/domainNames/serviceCertificates'
    }

    process {
        foreach ($service in $ServiceName) {
            $serviceObject = Get-AzClassicService -ServiceName $service

            $certificates = $null
            $certificates = Get-AzResource -ResourceName $serviceObject.Name -ResourceType $resourceType -ResourceGroupName $serviceObject.ResourceGroupName -ApiVersion $apiVersion

            if ($certificates) {
                foreach ($certificate in $certificates) {
                    $certData = $null
                    $certObject = $null
                    [byte[]]$certData = [System.Convert]::FromBase64String($certificate.Properties.Data)
                    $certObject = [System.Security.Cryptography.X509Certificates.X509Certificate2] $certData

                    $outObj = $null
                    $outObj = $certificate | Select-Object @{l = 'ServiceName'; e = { $serviceObject.ServiceName } }, ResourceName, ResourceGroupName, ResourceType, ResourceId, `
                    @{l = 'Thumbprint'; e = { $_.Properties.thumbprint } }, @{l = 'Algorithm'; e = { $_.Properties.thumbprintAlgorithm } }, @{l = 'Data'; e = { $_.Properties.Data } }, `
                    @{l = 'Subject'; e = { $certobject.Subject } }, @{l = 'Expires'; e = { $certObject.NotAfter } }

                    if ($outObj) {
                        $outObj.PSObject.TypeNames.Insert(0, 'AzClassicCertificate')
                        $outObj
                    }
                }
            }

            $certData = $null
            $certObject = $null
            $outObj = $null
        }
    }
}