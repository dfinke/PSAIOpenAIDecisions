$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '..\..\..\..\PSAIOpenAIDecisions.psd1') -Force

function Invoke-FailureCategorization {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$CsvPath,
        [Parameter(Mandatory)][string]$Question,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]]$Options
    )

    Import-Csv -LiteralPath $CsvPath | ForEach-Object {
        $failure = $_
        $component = $failure.Message | Get-OpenAIDecisionChoice -Question $Question -Choices $Options
        [pscustomobject]@{
            Id        = $failure.Id
            Component = $component
            Failure   = $failure.Message
        }
    }
}

Invoke-FailureCategorization -CsvPath (Join-Path $PSScriptRoot 'test-failures.csv') -Question 'Which component should investigate this failure?' -Options @('api', 'auth', 'database', 'build') |
    Format-Table -Wrap
