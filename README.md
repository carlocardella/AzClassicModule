# AzClassicModule

![CI](https://github.com/carlocardella/AzClassicModule/workflows/CI/badge.svg)

[CloudNotes.io](https://www.cloudnotes.io) 🔗

Manage Azure Service Manager (RDFE, classic) resources through Azure Resource Manager (ARM) Resource Providers. 

## Prequisites

Install the latest `Az` module:

- using PowershellGet:
  - `Install-Module -Name 'Az' -Scope 'CurrentUser' -Force`
- alternatively, install the individual modules:
  - `Find-Module -Name "Az.*" | Where-Object 'Author' -eq 'Microsoft Corporation' | Install-Module -Scope 'CurrentUser' -Force`

## Installation

### Powershell Gallery

Install the module from the PowershellGallery: https://www.powershellgallery.com/packages/AzClassicModule

```powershell
Install-Module -Name AzClassicModule -Scope 'CurrentUser' -AllowPrerelease -Force
```

### Clone on Windows

Download the zip file or cloune the repo locally: copy the AzureOps folder under

- `$env:PSUserProfile\Documents\WindowsPowershell\Modules` folder (for Windows Powershell)
- `$env:PSUserProfile\Documents\Powershell\Modules` folder (for Powershell 7 / Powershell Core)

### Clone on macOS

Download the zip file or cloune the repo locally: copy the AzClassicModule folder under `/Users/<user>/.local/share/powershell/Modules/` folder
