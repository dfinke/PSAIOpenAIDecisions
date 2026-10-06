#requires -Version 7.0

# Inspired by TypeSafe's Security Incidents workflow:
# https://evals.typesafe.ai/security_incidents
# Set OPENAI_API_KEY before running this example.

Import-Module (Join-Path $PSScriptRoot '..' 'PSAIOpenAIDecisions.psd1') -Force

$state = [ordered]@{
    alert = 'A PowerShell process read LSASS memory using comsvcs.dll on a production server.'
    asset = [ordered]@{
        environment = 'production'
        tier        = 'critical'
        owner       = 'platform operations'
    }
    open_tickets = @(
        'INC-1042: investigate unusual PowerShell activity on the production server'
    )
    registered_devices = @(
        'The owner normally uses a managed Windows laptop from the corporate network.'
    )
    scheduled_maintenance = @(
        'No maintenance window is scheduled.'
    )
    standing_authorizations = @(
        'Platform operations may run approved diagnostics during an incident.'
    )
}

$questions = @(
    New-OpenAIDecisionQuestion `
        -Name unauthorized_activity `
        -Type Predicate `
        -Instructions 'Does `alert` describe unauthorized activity given `standing_authorizations` and `scheduled_maintenance`?' `
        -Criteria @{ `
            true  = 'The activity is not explained by an authorization or maintenance window.'
            false = 'The activity is explained by an approved authorization or maintenance window.'
        }

    New-OpenAIDecisionQuestion `
        -Name evidence_strength `
        -Type Score `
        -Instructions 'How strong is the evidence that the activity in `alert` is harmful, given the asset and incident records?' `
        -Criteria @(
            'Weak: an unusual event with a plausible benign explanation.'
            'Moderate: suspicious activity with incomplete supporting evidence.'
            'Strong: a high impact asset and a clear malicious technique.'
        )

    New-OpenAIDecisionQuestion `
        -Name response `
        -Type Choice `
        -Instructions 'What immediate response best fits this alert and the available records?' `
        -Criteria @{ `
            notify_user    = 'Notify the asset owner and continue monitoring.'
            escalate_tier2 = 'Queue the alert for a security analyst.'
            kill_process   = 'Stop the suspicious process while preserving the account.'
            disable_account = 'Disable the suspected account because identity misuse is likely.'
            escalate_urgent = 'Escalate urgently because the production impact is severe or expanding.'
        }
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
