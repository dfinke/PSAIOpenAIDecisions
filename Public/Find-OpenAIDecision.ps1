function Find-OpenAIDecision {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$State,
        [Parameter(Mandatory,Position=0)][ValidateNotNullOrEmpty()][string]$Question,
        [Parameter()][string]$Model='gpt-6-luna'
    )
    begin { $candidates = [System.Collections.Generic.List[object]]::new() }
    process { $candidates.Add($State) }
    end {
        if ($candidates.Count -eq 0) { return }
        $options = [System.Collections.Generic.List[object]]::new()
        $originalByValue = @{}
        for ($i=0; $i -lt $candidates.Count; $i++) {
            $label = 'candidate{0:D4}' -f ($i+1)
            $candidate = $candidates[$i]
            $description = if ($candidate -is [string]) { $candidate } else { ConvertTo-Json -InputObject $candidate -Depth 50 -Compress }
            $options.Add([pscustomobject]@{ value=$label; description=$description })
            $originalByValue[$label] = $candidate
        }
        $options.Add([pscustomobject]@{ value='none'; description='None of the candidates answers the question.' })
        $definition = New-OpenAIDecisionQuestion -Type Choice -Name match -Instructions 'Which candidate best answers the question? Compare the candidates together. Select none if no candidate answers the question.' -Choices @($options)
        $response = Invoke-OpenAIDecision -InputObject $Question -Question $definition -Model $Model -ErrorAction Stop
        $answer = Get-OpenAIDecisionAnswer -Response $response -Name match
        if ($answer.type -eq 'refusal' -or $null -eq $answer.choice) { throw 'OpenAI declined or omitted the candidate choice.' }
        $selected = [string]$answer.choice
        if ($selected -eq 'none') { return }
        if (-not $originalByValue.ContainsKey($selected)) { throw "OpenAI returned an unknown candidate: '$selected'." }
        $PSCmdlet.WriteObject($originalByValue[$selected],$false)
    }
}
