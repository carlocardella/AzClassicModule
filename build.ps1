[CmdletBinding()]
param (
    [parameter(ParameterSetName = 'major')]
    [switch]$Major,
    
    [parameter(ParameterSetName = 'minor')]
    [switch]$Minor,
    
    [parameter(ParameterSetName = 'patch')]
    [switch]$Patch
)

Push-Location $PSScriptRoot

if ((Get-Module -ListAvailable 'Pester').Version.Major -notcontains 5) {
    Install-Module -Name 'Pester' -Force -AcceptLicense -AllowClobber -SkipPublisherCheck -Repository 'PSGallery' -Verbose -MinimumVersion '5.0.0.0' -ErrorAction 'Stop'
}

Import-Module -Name 'Pester' -MinimumVersion $([System.Version]::new(5, 0)) -ErrorAction 'Stop'

$outPester = Invoke-Pester -Path "$PSScriptRoot/Tests/" -Output Detailed -CI -PassThru

if ($outPester.FailedCount -eq 0) {
    $params = @{ }
    $params.ModuleDataFilePath = "$PSScriptRoot/src/AzClassicModule/AzClassicModule.psd1"
    if ($Major) { $params.Major = $true }
    if ($Minor) { $params.Minor = $true }
    if ($Patch) { $params.Patch = $true }

    Update-LSEModuleVersion @params -Force

    $buildNumber = $null
    $buildNumber = (Test-ModuleManifest -Path $params.ModuleDataFilePath).Version.ToString()
}
else {
    throw "$($outPester.FailedCount) tests failed"
}

if ($?) {
    Invoke-Command { git commit -am "Build module version $buildNumber"; git push }
}

Pop-Location