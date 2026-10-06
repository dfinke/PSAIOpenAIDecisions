<#
.SYNOPSIS
    Creates a named predicate question for the OpenAI Decisions API.
#>
function New-OpenAIYesNoQuestion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][Alias('Question')][ValidateNotNullOrEmpty()][string]$Instructions,
        [Parameter()][AllowNull()][string]$Name
    )
    New-OpenAIDecisionQuestion -Type Predicate -Name $Name -Instructions $Instructions
}

