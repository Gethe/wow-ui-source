#!/usr/bin/env pwsh
#Requires -Version 7.1

<#
.SYNOPSIS
    Exports UI source files for the current World of Warcraft build on the CDN.

.DESCRIPTION
    Exports UI source files for the current World of Warcraft build on the CDN.

    By default, this will perform an export for the current version on any
    listed product branch, but alternative builds can be queried via manual
    use of the BuildConfig and CDNConfig parameters.

.PARAMETER Product
    Specifies the game product to export UI source files for.

.PARAMETER OutputDirectory
    Specifies the root directory under which exported files will be placed.

.PARAMETER Region
    Specifies the CDN region to use for the export. Defaults to "us".

.EXAMPLE
    PS> ExportInterfaceFiles.ps1 -Product wow
#>

[CmdletBinding(PositionalBinding=$false)]
param (
    [Parameter(Mandatory)]
    [ValidateSet("wow", "wow_beta", "wow_classic", "wow_classic_beta", "wow_classic_ptr", "wow_classic_era", "wow_classic_era_ptr", "wow_classic_titan", "wowt", "wowxptr")]
    [string] $Product,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $OutputDirectory,

    [Parameter()]
    [ValidateSet("us", "eu", "kr", "cn")]
    [string] $Region = "us"
)

class TACTFile {
    [int] $ID
    [string] $Name
}

function ConvertTo-TACTPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [ValidateNotNull()]
        [TACTFile] $InputObject
    )

    $Parts = @()

    if ($InputObject.ID -gt 0) {
        $Parts += $InputObject.ID.ToString()
    }

    if ($null -ne $InputObject.Name) {
        $Parts += $InputObject.Name
    }

    return [String]::Join(";", $Parts)
}

function Export-TACTFiles {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [TACTFile] $InputObject,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $OutputDirectory,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $BuildConfig,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $CDNConfig
    )

    begin {
        $ListFile = New-TemporaryFile
        $ListFileStream = [System.IO.StreamWriter]::new($ListFile)
    }

    process {
        $ListFileStream.WriteLine((ConvertTo-TACTPath $_))
    }

    end {
        try {
            $ListFileStream.Close()
            $PSNativeCommandUseErrorActionPreference = $true
            & TACTTool --buildconfig $BuildConfig --cdnconfig $CDNConfig --mode list --inputvalue $ListFile --output $OutputDirectory
        } finally {
            Remove-Item -Force -ErrorAction Ignore $ListFile
        }
    }
}

function Get-ProductInfo {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory)]
        [ValidateSet("wow", "wow_beta", "wow_classic", "wow_classic_beta", "wow_classic_ptr", "wow_classic_era", "wow_classic_era_ptr", "wow_classic_titan", "wowt", "wowxptr", "wowz")]
        [string] $Product,

        [Parameter(Mandatory)]
        [ValidateSet("us", "eu", "kr", "cn")]
        [string] $Region
    )

    # Note that the response from the CDN isn't actually a CSV document, but
    # it's just about close enough that we can pretend it is one with pipe
    # delimiters. Some junk lines will be picked up, but these are filtered
    # by the region check.

    Invoke-WebRequest "https://us.version.battle.net/$Product/versions" `
        | ConvertFrom-Csv -Delimiter "|" -Header "Region", "BuildConfig", "CDNConfig", "Keyring", "Build", "Version", "ProductConfig" `
        | Where-Object { $_.Region -eq $Region } `
        | Select-Object -First 1
}

# Set up output directory and prune any potentially stale files.

New-Item -Type Directory $OutputDirectory -ErrorAction Ignore | Out-Null
Get-ChildItem -Filter Interface* $OutputDirectory | Remove-Item -Force -Recurse

# Query version information for products on the CDN. We do this for all
# products as we want to use this data for tagging later on. The priority
# value is used for tag selection later on, with lower values being preferred.

$Products = @(
    @{ Product = "wow";                 Priority = 1;   BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wowt";                Priority = 10;  BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wowxptr";             Priority = 10;  BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wow_beta";            Priority = 20;  BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wow_classic";         Priority = 1;   BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wow_classic_ptr";     Priority = 10;  BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wow_classic_beta";    Priority = 20;  BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wow_classic_era";     Priority = 1;   BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wow_classic_era_ptr"; Priority = 10;  BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
    @{ Product = "wow_classic_titan";   Priority = 1;   BuildConfig = $null; CDNConfig = $null; Build = $null; Schema = $null; Version = $null; }
)

$Products | ForEach-Object {
    $Info = (Get-ProductInfo -Product $_.Product -Region $Region)
    $Version = [Version] $Info.Version

    $_.BuildConfig = $Info.BuildConfig
    $_.CDNConfig = $Info.CDNConfig
    $_.Build = $Info.Build
    $_.Schema = [Version]::new($Version.Major, $Version.Minor, $Version.Build)
    $_.Version = $Version
}

$ProductInfo = ($Products | Where-Object -Property Product -EQ $Product)

# Next, we need to grab the textual manifest files from this build on the CDN.
# This consists of three files that list the filenames of Lua, XML, and TOC
# files in the interface.

$ManifestFiles = @(
    [TACTFile] @{ ID = 6067012; Name = "Interface/ui-code-list.txt" }
    [TACTFile] @{ ID = 6067013; Name = "Interface/ui-toc-list.txt" }
    [TACTFile] @{ ID = 6076661; Name = "Interface/ui-gen-addon-list.txt" }
)

$ManifestFiles | Export-TACTFiles -OutputDirectory $OutputDirectory -BuildConfig $ProductInfo.BuildConfig -CDNConfig $ProductInfo.CDNConfig

# Now that we've got the file lookup map, we can process the textual manifests
# and process the export of the UI source files themselves. It's expected that
# all files are in the TACT root and should be retrievable via the filehash
# alone without a listfile download.

$ManifestFiles `
    | ForEach-Object { Get-Content (Join-Path $OutputDirectory $_.Name) } `
    | Sort-Object `
    | Get-Unique `
    | ForEach-Object { [TACTFile] @{ Name = $_.Replace("\", "/") } } `
    | Export-TACTFiles -OutputDirectory $OutputDirectory -BuildConfig $ProductInfo.BuildConfig -CDNConfig $ProductInfo.CDNConfig

# Export metadata for the running action.
#
# Tag selection works by grouping all products with the same schema
# (ie. "11.0.7") and selecting the product within that group which has the
# lowest priority value. If that product matches the one being exported, then
# the tag value will evaluate to the schema. Otherwise, the tag will be unset.
#
# This logic means that we can prioritize retaining tags for live products
# over test ones. For example, let's say patch "11.1.0" appears on a PTR
# branch first. As that's the only product with that schema it will use it
# as a tag. Later, when that patch ends up pushed to a live branch, exports
# for the live branch will take ownership of the tag and future exports for
# test branches will not use it.

if ($env:GITHUB_OUTPUT) {
    $Tag = $Products `
        | Group-Object -Property Schema `
        | ForEach-Object { $_.Group | Sort-Object -Property Priority | Select-Object -First 1 } `
        | Where-Object -Property Product -EQ $Product `
        | Select-Object -First 1 -ExpandProperty Schema

    Add-Content $env:GITHUB_OUTPUT "build=$($ProductInfo.Build)"
    Add-Content $env:GITHUB_OUTPUT "schema=$($ProductInfo.Schema)"
    Add-Content $env:GITHUB_OUTPUT "tag=$Tag"
}

Set-Content (Join-Path $OutputDirectory version.txt) "$($ProductInfo.Version)"
