
Remove-Module AzClassicModule -Force -ErrorAction 'SilentlyContinue'
Update-TypeData -PrependPath "$PSScriptRoot\AzClassicModule.Types.ps1xml"
Update-FormatData -PrependPath "$PSScriptRoot\AzClassicModule.Formats.ps1xml"


Get-ChildItem -Path "$PSScriptRoot\*.ps1" | ForEach-Object { . $_.FullName }
