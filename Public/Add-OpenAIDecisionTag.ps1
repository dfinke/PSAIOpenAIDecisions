<#
.SYNOPSIS
    Adds every matching semantic tag to each input.
.DESCRIPTION
    Turns a label-to-description dictionary into independent predicate questions.
    All tag questions share one request per input. Tags whose yes probability
    meets Threshold are returned in Tags; individual probabilities and full
    answers are also retained. Inputs are not modified.
#>
function Add-OpenAIDecisionTag {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][object]$State,
        [Parameter(Mandatory, Position = 0)][System.Collections.IDictionary]$Tags,
        [Parameter(Position = 1)][ValidateRange(0.0, 1.0)][double]$Threshold = 0.5,
        [Parameter()][string]$Model = 'gpt-6-luna'
    )
    begin {
        if ($Tags.Count -eq 0) { throw 'Add-OpenAIDecisionTag requires at least one tag description.' }
        $questions = [System.Collections.Generic.List[object]]::new()
        $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($entry in $Tags.GetEnumerator()) {
            $name = [string]$entry.Key
            if ([string]::IsNullOrWhiteSpace($name)) { throw 'Tag names cannot be empty or whitespace.' }
            if (-not $seen.Add($name)) { throw "Duplicate tag name '$name'. Tag names are case-insensitive." }
            if ($entry.Value -isnot [string] -or [string]::IsNullOrWhiteSpace($entry.Value)) {
                throw "Tag '$name' requires a non-empty string description."
            }
            $questions.Add((New-OpenAIYesNoQuestion -Name $name -Question "Does this input match the tag '$name'?" -TrueCriteria $entry.Value -FalseCriteria 'The input does not meet the description of this tag.'))
        }
    }
    process {
        $response = Invoke-OpenAIDecision -InputObject $State -Question $questions.ToArray() -Model $Model -Raw -ErrorAction Stop
        $matchingTags = [System.Collections.Generic.List[string]]::new()
        foreach ($question in $questions) {
            $answer = Get-OpenAIDecisionAnswer -Response $response -Name $question.Name
            if ($answer.type -eq 'refusal' -or $null -eq $answer.probability) {
                throw "OpenAI declined or omitted the probability for tag '$($question.Name)'."
            }
            $probability = [double]$answer.probability
            if ([double]::IsNaN($probability) -or $probability -lt 0 -or $probability -gt 1) {
                throw "OpenAI returned an invalid probability for tag '$($question.Name)'."
            }
            if ($probability -ge $Threshold) { $matchingTags.Add($question.Name) }
        }
        $result = ConvertTo-OpenAIDecisionEnrichedResult -State $State -Response $response
        $propertyName = 'Tags'
        while ($null -ne $result.PSObject.Properties[$propertyName]) { $propertyName = "OpenAIDecision_$propertyName" }
        $result.PSObject.Properties.Add([psnoteproperty]::new($propertyName, [string[]]$matchingTags.ToArray()))
        $result
    }
}
