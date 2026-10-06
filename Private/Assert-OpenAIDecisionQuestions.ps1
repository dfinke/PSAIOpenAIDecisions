function Assert-OpenAIDecisionQuestions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [object[]] $Questions
    )

    if ($Questions.Count -eq 0) { throw 'Questions must contain at least one question.' }
    foreach ($question in $Questions) {
        if ($null -eq $question) { throw 'A question cannot be null.' }
        $type = [string]$question.type
        if ($type -notin @('predicate', 'choice', 'score')) {
            throw "Unsupported question type '$type'. Use predicate, choice, or score."
        }
        if ([string]::IsNullOrWhiteSpace([string]$question.instructions)) {
            throw "A '$type' question requires non-empty instructions."
        }
        $hasName = if ($question -is [System.Collections.IDictionary]) { $question.Contains('name') } else { $null -ne $question.PSObject.Properties['name'] }
        if ($hasName -and [string]::IsNullOrWhiteSpace([string]$question.name)) {
            throw 'Question name cannot be empty when provided.'
        }
        if ($type -eq 'choice') {
            $choices = @($question.choices)
            if ($choices.Count -eq 0) { throw 'A choice question requires at least one choice.' }
            foreach ($choice in $choices) {
                $hasValue = if ($choice -is [System.Collections.IDictionary]) { $choice.Contains('value') } elseif ($null -ne $choice) { $null -ne $choice.PSObject.Properties['value'] } else { $false }
                if (-not $hasValue) {
                    throw 'Each choice must have a value and may have a description.'
                }
                if ($choice.value -isnot [string] -and $choice.value -isnot [bool]) {
                    throw 'Choice values must be strings or Booleans.'
                }
            }
        }
        if ($type -eq 'score') {
            $levels = @($question.levels)
            if ($levels.Count -eq 0) { throw 'A score question requires at least one level.' }
            foreach ($level in $levels) {
                $hasLabel = if ($level -is [System.Collections.IDictionary]) { $level.Contains('label') } elseif ($null -ne $level) { $null -ne $level.PSObject.Properties['label'] } else { $false }
                if (-not $hasLabel -or [string]::IsNullOrWhiteSpace([string]$level.label)) {
                    throw 'Each score level requires a non-empty label.'
                }
            }
        }
    }
    $names = @($Questions | ForEach-Object {
        $hasName = if ($_ -is [System.Collections.IDictionary]) { $_.Contains('name') } else { $null -ne $_.PSObject.Properties['name'] }
        if ($hasName) { [string]$_.name }
    } | Where-Object { $_ })
    if (@($names | Select-Object -Unique).Count -ne $names.Count) { throw 'Question names must be unique.' }
}
