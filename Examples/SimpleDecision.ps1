# Run from this checkout with PowerShell 7+ and OPENAI_API_KEY set.
Import-Module (Join-Path $PSScriptRoot '..\PSAIOpenAIDecisions.psd1') -Force

$question = New-OpenAIYesNoQuestion `
    -Name mentionsRefund `
    -Question 'Is the customer asking for a refund?'

$response = Invoke-OpenAIDecision `
    -Input 'I was charged twice for my order. Please refund the duplicate payment.' `
    -Question $question

$response.answers.mentionsRefund.probability

