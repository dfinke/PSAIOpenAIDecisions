#requires -Version 7.0

# Inspired by TypeSafe's primitives example:
# https://docs.typesafe.ai/primitives
# Set OPENAI_API_KEY before running this example.

Import-Module (Join-Path $PSScriptRoot '..' 'PSAIOpenAIDecisions.psd1') -Force

$state = [ordered]@{
    ticket_message = 'My flight was cancelled. Can I get a refund?'
    refund_policy  = 'Cancelled flights are eligible for a full refund.'
}

$questions = @(
    New-OpenAIDecisionQuestion `
        -Name refund_requested `
        -Type Predicate `
        -Instructions 'Does `ticket_message` request a refund?'

    New-OpenAIDecisionQuestion `
        -Name request_type `
        -Type Choice `
        -Instructions 'What is the main request in `ticket_message`?' `
        -Criteria @{ `
            refund      = 'The customer wants money returned.'
            rebooking   = 'The customer wants a replacement flight.'
            information = 'The customer is asking for information only.'
        }

    New-OpenAIDecisionQuestion `
        -Name frustration `
        -Type Score `
        -Instructions 'How frustrated does the customer appear in `ticket_message`?' `
        -Criteria @(
            'Calm and neutral.'
            'Concerned but civil.'
            'Very angry or using strong language.'
        )
)

$response = Invoke-OpenAIDecision -State $state -Question $questions

'Merged OpenAI Decisions response:'
$response | ConvertTo-Json -Depth 10

# Add -Raw to the Invoke-OpenAIDecision call when you need only the API response.

$answerEntries = @($response.answers.GetEnumerator() | ForEach-Object {
    [pscustomobject]@{ Name = [string]$_.Key; Value = $_.Value }
})
$summary = foreach ($answerEntry in $answerEntries) {
    $answer = $answerEntry.Value
    $decision = $null
    $probability = $null
    $confidence = $null

    switch ($answer.type.ToLowerInvariant()) {
        'predicate' {
            $decision = if ($answer.probability -ge 0.5) { 'True' } else { 'False' }
            $probability = [math]::Round($answer.probability, 3)
        }
        'choice' {
            $decision = $answer.choice
            $confidence = [math]::Round($answer.confidence, 3)
        }
        'score' {
            $decision = $answer.score
            $confidence = [math]::Round($answer.confidence, 3)
        }
    }

    [pscustomobject]@{
        Question    = $answerEntry.Name
        Type        = $answer.type
        Decision    = $decision
        Probability = $probability
        Confidence  = $confidence
    }
}

'Readable decisions:'
$summary | Format-Table -AutoSize -Wrap
