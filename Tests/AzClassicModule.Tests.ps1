Remove-Module 'AzClassicModule' -Force -ErrorAction 'SilentlyContinue'
Import-Module "$PSScriptRoot/../src/AzClassicModule" -Force -ErrorAction 'Stop'
Remove-Module 'MockAzure' -Force -ErrorAction 'SilentlyContinue'
Import-Module 'MockAzure' -Force
Import-Module 'Az.Resources'

