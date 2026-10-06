#requires -Version 7.0

# Set OPENAI_API_KEY before running this example.

Import-Module (Join-Path $PSScriptRoot '..' 'PSAIOpenAIDecisions.psd1') -Force

$feedback = [pscustomobject] @{
    message = 'The customer is blocked by an outage and may cancel.'
}

$questions = @(
    New-OpenAIDecisionQuestion `
        -Name churn `
        -Type Predicate `
        -Instructions 'Is this an active churn threat?' `
        -Criteria @{ `
            true = 'The customer may leave or cancel.'
        false    = 'The customer is stable and engaged.'
    }

    New-OpenAIDecisionQuestion `
        -Name route `
        -Type Choice `
        -Instructions 'Which team should handle this?' `
        -Criteria @{ `
            support = 'The issue needs technical support.'
        sales       = 'The issue concerns pricing or renewal.'
    }

    New-OpenAIDecisionQuestion `
        -Name urgency `
        -Type Score `
        -Instructions 'How urgent is this?' `
        -Criteria @('Can wait', 'This week', 'Today')
)

$result = Invoke-OpenAIDecision -State $feedback -Question $questions

# The default result keeps the input state next to the OpenAI Decisions response. This view
# makes the message and the corresponding decisions easy to read together.
$answerEntries = if ($result.answers -is [System.Collections.IDictionary]) {
    @($result.answers.GetEnumerator())
}
else {
    @($result.answers.PSObject.Properties | ForEach-Object {
            [pscustomobject] @{
                Key   = $_.Name
                Value = $_.Value
            }
        })
}

$summary = foreach ($answerEntry in $answerEntries) {
    $answer = $answerEntry.Value

    switch ($answer.type.ToLowerInvariant()) {
        'predicate' {
            [pscustomobject] @{
                Message           = $result.State.message
                Question          = $answerEntry.Key
                Type              = $answer.type
                Result            = if ($answer.probability -ge 0.5) { 'True' } else { 'False' }
                ProbabilityOfTrue = [math]::Round($answer.probability, 3)
            }
        }
        'choice' {
            [pscustomobject] @{
                Message    = $result.State.message
                Question   = $answerEntry.Key
                Type       = $answer.type
                Result     = $answer.choice
                Confidence = [math]::Round($answer.confidence, 3)
            }
        }
        'score' {
            [pscustomobject] @{
                Message    = $result.State.message
                Question   = $answerEntry.Key
                Type       = $answer.type
                Result     = $answer.score
                Confidence = [math]::Round($answer.confidence, 3)
            }
        }
    }
}

Write-Host 'Merged OpenAI Decisions response:' -ForegroundColor Cyan
$result | Format-Table

Write-Host 'Readable summary:' -ForegroundColor Cyan
$summary | Format-Table -AutoSize -Wrap
