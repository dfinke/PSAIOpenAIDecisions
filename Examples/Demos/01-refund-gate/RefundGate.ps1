# Ask OpenAI Decisions whether the customer wants a refund, then print the matching route.
param([string] $Path = "$PSScriptRoot/message.txt")

$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../../../PSAIOpenAIDecisions.psd1"

$question = New-OpenAIDecisionQuestion -Name refund -Type Predicate `
    -Instructions 'Does the customer ask for money back?'

$decision = Get-Content -LiteralPath $Path -Raw |
    Invoke-OpenAIDecision -Question $question

if ($decision.refund -ge 0.5) {
    'refunds'
} else {
    'normal'
}


