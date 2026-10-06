function ConvertTo-OpenAIDecisionEnrichedResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$State,
        [Parameter(Mandatory)][object]$Response
    )

    $result = [ordered]@{}
    if ($State -is [System.Collections.IDictionary]) {
        foreach ($key in $State.Keys) {
            $name = [string]$key
            if (-not [string]::IsNullOrWhiteSpace($name)) { $result[$name] = $State[$key] }
        }
    }
    elseif ($State -is [string] -or $State -is [ValueType] -or $State -is [array]) {
        $result.State = $State
    }
    else {
        foreach ($property in $State.PSObject.Properties) { $result[$property.Name] = $property.Value }
    }

    foreach ($property in $Response.PSObject.Properties | Where-Object Name -notin @('answers', 'usage')) {
        $name = $property.Name
        while ($result.Contains($name)) { $name = "OpenAIDecision_$name" }
        $result[$name] = $property.Value
    }

    $answerEntries = @()
    if ($Response.answers -is [System.Collections.IDictionary]) {
        $answerEntries = @($Response.answers.GetEnumerator() | ForEach-Object {
            [pscustomobject]@{ Name = [string]$_.Key; Value = $_.Value }
        })
    }
    elseif ($Response.answers -is [array]) {
        $answerEntries = @($Response.answers | ForEach-Object {
            [pscustomobject]@{ Name = [string]$_.name; Value = $_ }
        })
    }
    elseif ($null -ne $Response.answers) {
        $answerEntries = @($Response.answers.PSObject.Properties | ForEach-Object {
            [pscustomobject]@{ Name = $_.Name; Value = $_.Value }
        })
    }

    foreach ($entry in $answerEntries) {
        $answer = $entry.Value
        $value = switch ([string]$answer.type) {
            'predicate' { $answer.probability }
            'choice' { $answer.choice }
            'score' { $answer.score }
            default { $answer }
        }
        $name = $entry.Name
        while ($result.Contains($name)) { $name = "OpenAIDecision_$name" }
        $result[$name] = $value
    }

    if ($null -ne $Response.usage) {
        $name = 'usage'
        while ($result.Contains($name)) { $name = "OpenAIDecision_$name" }
        $result[$name] = $Response.usage
    }
    if ($null -ne $Response.answers) {
        $name = 'answers'
        while ($result.Contains($name)) { $name = "OpenAIDecision_$name" }
        $result[$name] = $Response.answers
    }
    [pscustomobject]$result
}
