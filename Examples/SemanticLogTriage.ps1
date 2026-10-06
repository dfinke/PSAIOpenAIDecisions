#requires -Version 7.0

<##
.SYNOPSIS
    Classifies a few log lines with typed OpenAI Decisions questions.

.DESCRIPTION
    Each log line is evaluated with the same predicate and Choice questions.
    OpenAI Decisions returns typed answers; PowerShell turns them into sortable properties.
#>

[CmdletBinding()]
param(
    [string[]] $LogLine = @(
        'INFO web service started successfully on port 8080.'
        'WARN DNS lookup timed out while connecting to api.internal.'
        'ERROR invalid JSON in the deployment configuration.'
        'ALERT unauthorized login followed by a privilege escalation attempt.'
    )
)

# Set OPENAI_API_KEY before running this example.
Import-Module (Join-Path $PSScriptRoot '..' 'PSAIOpenAIDecisions.psd1') -Force

$questions = @(
    New-OpenAIDecisionQuestion `
        -Name critical_security_risk `
        -Type Predicate `
        -Instructions 'Is this log line evidence of a critical security risk or attack?' `
        -Criteria @{ `
            true = 'A breach, unauthorized access, credential attack, or privilege escalation.'
        false    = 'A normal operational message or a non-security application failure.'
    }

    New-OpenAIDecisionQuestion `
        -Name root_cause `
        -Type Choice `
        -Instructions 'What is the most likely root-cause category for this log line?' `
        -Criteria @{ `
            auth = 'Authentication, credentials, identity, authorization, or access failure.'
        network  = 'Network, DNS, connection, socket, timeout, or transport failure.'
        syntax   = 'Syntax, parsing, malformed configuration, or invalid format failure.'
        unknown  = 'No clear root-cause category is supported by the line.'
    }
)

$results = foreach ($line in $LogLine) {
    $state = @{ log_line = $line }
    $response = Invoke-OpenAIDecision `
        -State $state `
        -Question $questions

    $security = $response.answers.critical_security_risk
    $cause = $response.answers.root_cause
    $criticalRisk = [math]::Round([double] $security.probability, 3)
    $emoji = if ($criticalRisk -ge 0.8) {
        '🔴'
    }
    elseif ($criticalRisk -ge 0.5) {
        '🟠'
    }
    else {
        '🟢'
    }

    [pscustomobject]@{
        Indicator           = $emoji
        LogLine             = $response.State.log_line
        CriticalRisk        = $criticalRisk
        RootCause           = [string] $cause.choice
        RootCauseConfidence = [math]::Round([double] $cause.confidence, 3)
    }
}

$results |
Sort-Object CriticalRisk -Descending |
Format-Table Indicator, CriticalRisk, RootCause, RootCauseConfidence, LogLine -Wrap -AutoSize
