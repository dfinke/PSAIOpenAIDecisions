# OpenAI Decisions selects the rule. PowerShell maps its label to a bounded output object.
function Get-LoanDecision {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [pscustomobject] $State
    )

    begin {
        . "$PSScriptRoot/New-LoanApplication.ps1"
        Import-Module (Join-Path $PSScriptRoot '..\..\..\PSAIOpenAIDecisions.psd1') -ErrorAction Stop
        $loanModel = & "$PSScriptRoot/LoanModel.ps1"
    }

    process {
        # Refresh the percentages in case a field changed after construction.
        $application = New-LoanApplication -Income $State.Income -Requested $State.Requested `
            -CreditScore $State.CreditScore -Debt $State.Debt
        $response = Invoke-OpenAIDecision -InputObject $application -Question $loanModel.Question `
            -Model $loanModel.Model -ErrorAction Stop
        $answer = $response.answers.outcome
        if ([string]$answer.type -eq 'refusal') {
            throw 'OpenAI Decisions refused this loan outcome evaluation. No loan outcome was selected.'
        }

        $selected = [string] $answer.choice
        if (-not $loanModel.Outcomes.Contains($selected)) {
            throw "OpenAI Decisions returned an unknown loan outcome: '$selected'."
        }
        $outcome = $loanModel.Outcomes[$selected]

        [pscustomobject]@{
            Decision = $outcome.Decision
            Reason   = $outcome.Reason
        }
    }
}



