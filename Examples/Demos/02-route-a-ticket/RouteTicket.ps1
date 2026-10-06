# Ask OpenAI Decisions which team owns a support ticket, then route it only when the leading choice is clear.
param(
    [string] $Path = "$PSScriptRoot/ticket.txt",
    [ValidateRange(0.0, 1.0)]
    [double] $Threshold = 0.8
)

$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../../../PSAIOpenAIDecisions.psd1"

$question = New-OpenAIDecisionQuestion -Name team -Type Choice `
    -Instructions 'Which team owns this request?' `
    -Criteria @{
        billing  = 'A charge, invoice, payment, or refund issue.'
        shipping = 'A delivery, tracking, or missing package issue.'
        account  = 'A sign-in or account access issue.'
        other    = 'A request outside the billing, shipping, or account teams.'
    }

$ticket = Get-Content -LiteralPath $Path -Raw
$decision = $ticket | Invoke-OpenAIDecision -Question $question
$category = $decision.team

# The threshold applies to the leading category's probability.
$selectedOption = @($decision.answers.team.probabilities | Where-Object { [string]$_.value -eq $category } | Select-Object -First 1)
if ($selectedOption.Count -eq 0) { throw "OpenAI omitted probability for team '$category'." }
$probability = [double] $selectedOption[0].probability

if ($probability -lt $Threshold) {
    $queue = 'triage'
}
else {
    $queue = switch ($category) {
        billing  { 'payments' }
        shipping { 'logistics' }
        account  { 'identity' }
        other    { 'triage' }
        default  { throw "OpenAI Decisions returned an unexpected team: '$category'." }
    }
}

[pscustomobject]@{
    Ticket     = ($ticket -split "`r?`n" | Where-Object { $_ -match '^Subject:' } | Select-Object -First 1) -replace '^Subject:\s*', ''
    Team       = $category
    Probability = $probability
    Threshold  = $Threshold
    Queue      = $queue
}


