# Route each sample test failure to an investigating component.
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../../../PSAIOpenAIDecisions.psd1" -Force

$question = 'Which component should investigate this failure?'
$components = @('api', 'auth', 'database', 'build')
Import-Csv "$PSScriptRoot/test-failures.csv" | ForEach-Object {
    $failure = $_
    $component = $failure.Message | Get-OpenAIDecisionChoice $question $components
    [pscustomobject]@{
        Id        = $failure.Id
        Component = $component
        Failure   = $failure.Message
    }
} | Format-Table -Wrap
