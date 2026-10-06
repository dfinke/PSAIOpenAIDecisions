<#
.SYNOPSIS
    Creates a PowerShell-friendly question for the OpenAI Decisions API.
.DESCRIPTION
    Choice entries may be strings or objects with value and optional description.
    Score levels may be labels or objects with label and optional description.
#>
function New-OpenAIDecisionQuestion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateSet('Predicate','Choice','Score')][string]$Type,
        [Parameter(Mandatory)][Alias('Question')][ValidateNotNullOrEmpty()][string]$Instructions,
        [Parameter()][AllowNull()][string]$Name,
        [Parameter()][AllowNull()][object[]]$Choices,
        [Parameter()][AllowNull()][object[]]$Levels
    )

    if ($Type -eq 'Choice' -and $Choices.Count -eq 0) { throw 'Choice questions require -Choices.' }
    if ($Type -ne 'Choice' -and $null -ne $Choices) { throw "$Type questions do not accept -Choices." }
    if ($Type -eq 'Score' -and $Levels.Count -eq 0) { throw 'Score questions require -Levels.' }
    if ($Type -ne 'Score' -and $null -ne $Levels) { throw "$Type questions do not accept -Levels." }

    $normalizedChoices = @()
    foreach ($choice in $Choices) {
        if ($choice -is [string] -or $choice -is [bool]) { $normalizedChoices += [pscustomobject]@{ value = $choice } }
        else { $normalizedChoices += $choice }
    }
    $normalizedLevels = @()
    foreach ($level in $Levels) {
        if ($level -is [string]) { $normalizedLevels += [pscustomobject]@{ label = $level } }
        else { $normalizedLevels += $level }
    }

    [pscustomobject][ordered]@{
        Name = $Name
        Type = $Type
        Instructions = $Instructions
        Choices = if ($Type -eq 'Choice') { $normalizedChoices } else { $null }
        Levels = if ($Type -eq 'Score') { $normalizedLevels } else { $null }
    }
}

