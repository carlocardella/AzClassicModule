Remove-Module AzClassicModule -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../AzClassicModule -Force -ErrorAction Stop
Remove-Module MockAzure -Force -ErrorAction SilentlyContinue
Import-Module MockAzure -Force
Import-Module Az.Resources

Describe -Name 'Get-AzClassicService' {
    InModuleScope AzClassicModule {
        Mock Get-AzResource -Verifiable {
            Get-MockAzClassicComputeDomainNames
        }

        It 'Should not throw' {
            { Get-AzClassicService -Verbose } | Should -Not -Throw
        }

        It 'Returns a list of Classic Cloud Services' {
            @(Get-AzClassicService).Count | Should -Be 64
        } -Skip

        It 'Returns all service names matching a wildcard search' {
            @(Get-AzClassicService -ServiceName job*).Count | Should -Be 16
        } -Skip

        It 'Does not throw if the service does not exist' {
            { Get-AzClassicService -ServiceName 'nonexistentservice' } | Should -Not -Throw
        }

        It 'Calls all Mocks' {
            Assert-VerifiableMock
        }
    }
}

Describe 'Reset-AzClassicRoleInstance' {
    InModuleScope 'AzClassicModule' {
        Mock Get-AzClassicRoleInstance -Verifiable {
            Get-MockAzClassicComputeRoleInstance
        }

        Mock Invoke-AzResourceAction -Verifiable {
            $true
        }

        It 'Does not throw' {
            { Reset-AzClassicRoleInstance -ServiceName 'jobruntimedataRG' -Force } | Should -Not -Throw
        }

        It 'Reset all instances in a role' {
            @(Reset-AzClassicRoleInstance -ServiceName 'jobruntimedataRG' -Force).Count | Should -Be 25
        } -Skip

        It 'Does not throw if the service does not exist' {
            { Reset-AzClassicRoleInstance -ServiceName 'nonexistentservice' -Force } | Should -Not -Throw
        }

        It 'Calls all Mocks' {
            Assert-VerifiableMock
        }
    }
}