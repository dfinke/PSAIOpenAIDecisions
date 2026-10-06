<#
.SYNOPSIS
    Scores each input on an ordered Decisions scale.
.DESCRIPTION
    Returns one numeric score per input. Levels start at zero and are defined
    in the order supplied. Use Invoke-OpenAIDecision when the full answer,
    confidence, and probability distribution are needed.
#>
function Get-OpenAIDecisionScore {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][object]$State,
        [Parameter(Mandatory, Position = 0)][ValidateNotNullOrEmpty()][string]$Question,
        [Parameter(Mandatory, Position = 1, ValueFromRemainingArguments)][ValidateCount(2, 10)][ValidateNotNullOrEmpty()][string[]]$Levels,
        [Parameter()][string]$Model = 'gpt-6-luna'
    )
    begin {
        foreach ($level in $Levels) {
            if ([string]::IsNullOrWhiteSpace($level)) { throw 'Score level descriptions cannot be empty or whitespace.' }
        }
        $definition = New-OpenAIDecisionQuestion -Type Score -Name rating -Instructions $Question -Levels $Levels
        $maximumScore = $Levels.Count - 1
    }
    process {
        $response = Invoke-OpenAIDecision -InputObject $State -Question $definition -Model $Model -ErrorAction Stop
        $answer = Get-OpenAIDecisionAnswer -Response $response -Name rating
        if ($answer.type -eq 'refusal' -or $null -eq $answer.score) { throw "OpenAI declined or omitted the score for question 'rating'." }
        $score = [double]$answer.score
        if ([double]::IsNaN($score) -or $score -lt 0 -or $score -gt $maximumScore) {
            throw "OpenAI returned an invalid score for question 'rating'. Expected a value from 0 to $maximumScore."
        }
        $score
    }
}
