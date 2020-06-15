function Get-AzClassicStorageKey {
    <#
    .SYNOPSIS
    Returns the Primary and Secondary keys for a Classic Storage Account read as ARM resources
    
    .PARAMETER StorageAccountName
    Storage Account Name to look for. Supports wildcards
    
    .EXAMPLE
    Get-AzClassicStorageKey -StorageAccountName myclassicstorage

    Primary Secondary   StorageAccountName
    ------- ---------   ------------------
    xxxxxxx xxxxxxxxx   myclassicstorage
    
    .EXAMPLE
    Get-AzClassicStorageAccount | Get-AzClassicStorageKey

    Primary Secondary   StorageAccountName
    ------- ---------   ------------------
    xxxxxxx xxxxxxxxx   myclassicstorage
    #>
    
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Name')]
        [OutputType('AzClassicStorageKey')]
        [string[]]$StorageAccountName
    )

    process {
        $storageAccounts = Get-AzClassicStorageAccount -StorageAccountName $StorageAccountName

        foreach ($storage in $storageAccounts) {
            # Get-AzResource -ResourceType 'Microsoft.ClassicStorage/storageAccounts' | Where-Object 'Name' -Like $storage
            $keys = $null
            $keys = Invoke-AzResourceAction -ResourceType 'Microsoft.ClassicStorage/storageAccounts' -ResourceName $storage -Action 'listKeys' -ResourceGroupName $storage.ResourceGroupName -Force

            $outObj = $null
            $outObj = [pscustomobject]@{
                'Primary'            = $keys.primaryKey;
                'Secondary'          = $keys.secondaryKey;
                'StorageAccountName' = $storage
            }
            $outObj.PSObject.TypeNames.Insert(0, 'AzClassicStorageKey')

            $outObj
        }
    }
}