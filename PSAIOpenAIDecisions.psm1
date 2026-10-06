<#
.SYNOPSIS
    Creates named PowerShell commands for OpenAI Decisions.
#>
$privatePath = Join-Path $PSScriptRoot 'Private'
$publicPath = Join-Path $PSScriptRoot 'Public'
foreach ($script in Get-ChildItem -LiteralPath $privatePath -Filter '*.ps1' -File | Sort-Object Name) { . $script.FullName }
foreach ($script in Get-ChildItem -LiteralPath $publicPath -Filter '*.ps1' -File | Sort-Object Name) { . $script.FullName }
Export-ModuleMember -Function @(
    'Invoke-OpenAIDecision'
    'New-OpenAIDecisionQuestion'
    'New-OpenAIYesNoQuestion'
    'Add-OpenAIDecisionAnnotation'
    'Add-OpenAIDecisionTag'
    'Find-OpenAIDecision'
    'Get-OpenAIDecisionChoice'
    'Get-OpenAIDecisionRanking'
    'Get-OpenAIDecisionScore'
    'Select-OpenAIDecision'
    'Test-OpenAIDecision'
)
