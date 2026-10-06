# Compare all log lines together and return the one that best explains the failure.
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../../PSAIOpenAIDecisions.psd1" -Force

Get-Content "$PSScriptRoot/checkout.log" |
    Find-OpenAIDecision 'Which entry best explains why customers cannot complete checkout?'
