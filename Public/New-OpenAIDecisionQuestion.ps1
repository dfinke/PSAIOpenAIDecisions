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
        [Parameter(Mandatory)][ValidateSet('Predicate','Noul','Choice','Score')][string]$Type,
        [Parameter(Mandatory)][Alias('Question')][ValidateNotNullOrEmpty()][string]$Instructions,
        [Parameter()][AllowNull()][string]$Name,
        [Parameter()][AllowNull()][object[]]$Choices,
        [Parameter()][AllowNull()][object[]]$Levels,
        [Parameter()][AllowNull()][object]$Criteria
    )

    if ($Type -eq 'Noul') { $Type = 'Predicate' }
    if ($null -ne $Criteria) {
        if ($Type -eq 'Choice' -and $null -eq $Choices) {
            if ($Criteria -is [System.Collections.IDictionary]) {
                $Choices = @($Criteria.GetEnumerator() | ForEach-Object {
                    if ($null -eq $_.Value) { [pscustomobject]@{ value = [string]$_.Key } }
                    else { [pscustomobject]@{ value = [string]$_.Key; description = [string]$_.Value } }
                })
            } else { $Choices = @($Criteria) }
        }
        elseif ($Type -eq 'Score' -and $null -eq $Levels) { $Levels = @($Criteria) }
        elseif ($Type -eq 'Predicate' -and $Criteria -is [System.Collections.IDictionary]) {
            $trueText = if ($Criteria.Contains('true')) { [string]$Criteria['true'] } else { '' }
            $falseText = if ($Criteria.Contains('false')) { [string]$Criteria['false'] } else { '' }
            if ($trueText -or $falseText) { $Instructions += "`n`nTrue: $trueText`nFalse: $falseText" }
        }
    }

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

