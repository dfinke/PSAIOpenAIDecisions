[CmdletBinding()]
param([string]$FullPath)
$moduleName = 'PSAIOpenAIDecisions'
$sourcePath = (Resolve-Path -LiteralPath $PSScriptRoot).Path
if ([string]::IsNullOrWhiteSpace($FullPath)) {
    $moduleRoots = @($env:PSModulePath -split [System.IO.Path]::PathSeparator | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -notlike "$PSHOME*" })
    if ($moduleRoots.Count -eq 0) { throw 'Could not find a module directory in PSModulePath. Pass -FullPath explicitly.' }
    $FullPath = Join-Path $moduleRoots[0] $moduleName
}
$targetPath = [System.IO.Path]::GetFullPath($FullPath)
New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $sourcePath 'PSAIOpenAIDecisions.psd1') -Destination $targetPath -Force
Copy-Item -LiteralPath (Join-Path $sourcePath 'PSAIOpenAIDecisions.psm1') -Destination $targetPath -Force
foreach ($folder in @('Public','Private')) { Copy-Item -LiteralPath (Join-Path $sourcePath $folder) -Destination $targetPath -Recurse -Force }
Write-Host "Installed PSAIOpenAIDecisions to $targetPath"
