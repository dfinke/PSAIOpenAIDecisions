<#
.SYNOPSIS
    Adds named Decisions answers to each input.
.DESCRIPTION
    Evaluates all supplied questions in one request per input. Object properties
    remain alongside named answer values and the full response. String inputs
    appear under State. The input itself is not modified.
#>
function Add-OpenAIDecisionAnnotation {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][object]$State,
        [Parameter(Mandatory, Position = 0)][ValidateNotNullOrEmpty()][object[]]$Question,
        [Parameter()][string]$Model = 'gpt-6-luna'
    )
    process {
        $response = Invoke-OpenAIDecision -InputObject $State -Question $Question -Model $Model -Raw -ErrorAction Stop
        ConvertTo-OpenAIDecisionEnrichedResult -State $State -Response $response
    }
}
