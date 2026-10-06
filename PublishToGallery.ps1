[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [string]$NuGetApiKey = $env:NuGetApiKey,
    [string]$Repository = 'PSGallery'
)

$manifestPath = Join-Path $PSScriptRoot 'PSAIOpenAIDecisions.psd1'
$manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
if ($manifest.Name -ne 'PSAIOpenAIDecisions') { throw "Expected PSAIOpenAIDecisions.psd1 but found '$($manifest.Name)'." }
if ($PSCmdlet.ShouldProcess("$($manifest.Name) $($manifest.Version) to $Repository", 'Publish PowerShell module')) {
    Publish-Module -Path $PSScriptRoot -Repository $Repository -NuGetApiKey $NuGetApiKey -ErrorAction Stop
}
