function Get-AzClassicStorageAccount {
    <#
    .SYNOPSIS
    Returns Classic Storage Account details read as ARM resource

    .PARAMETER StorageAccountName
    Storage Account Name to look for. Supports wildcards

    .EXAMPLE
    Get-AzClassicStorageAccount -StorageAccountName *mystor*

    StorageAccountName : mystorageaccount
    ResourceGroupName  : Default-Storage-CentralUS
    Location           : centralus
    CreationTime       : 11/18/2016 7:29:45 PM
    AccountType        : Standard-GRS
    #>

    [CmdletBinding()]
    [OutputType('AzClassicStorageAccount')]
    param (
        [parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [string[]]$StorageAccountName = '*'
    )

    process {
        $resourceType = 'Microsoft.ClassicStorage/storageAccounts'
        foreach ($storage in $StorageAccountName) {
            $outObj = $null
            $resources = $null

            $resources = Get-AzResource -ResourceType $resourceType | Where-Object 'Name' -Like $storage

            @($resources) | ForEach-Object {
                $outObj = Get-AzResource -ResourceType $resourceType -Name $_.Name -ResourceGroupName $_.ResourceGroupName | Select-Object *
                $outObj.PSObject.TypeNames.Insert(0, 'AzClassicStorageAccount')
                $outObj
            }
        }
    }
}