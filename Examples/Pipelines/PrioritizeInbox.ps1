# Keep messages needing a reply, rank the top three, and add the responsible team.
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../../PSAIOpenAIDecisions.psd1" -Force

$messages = @(
    'Thanks for your help. Everything works now!'
    'Do you ship to Canada?'
    'Checkout is down. No customers can place orders.'
    'Our event starts in two hours and tickets will not download.'
    'I was charged twice. Please refund the duplicate.'
)

$team = New-OpenAIDecisionQuestion -Name team -Type Choice `
    -Instructions 'Which team should handle this message?' `
    -Criteria @{
        billing = 'Charges, invoices, payments, and refunds.'
        support = 'Broken features or services.'
        sales   = 'Product and shipping questions.'
    }

$messages |
    Select-OpenAIDecision 'Does this need a reply?' |
    Get-OpenAIDecisionRanking 'Does this need urgent attention?' -Top 3 |
    Add-OpenAIDecisionAnnotation -Question $team |
    Format-Table State, team -Wrap
