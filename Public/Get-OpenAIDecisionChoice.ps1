function Get-OpenAIDecisionChoice {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$State,
        [Parameter(Mandatory,Position=0)][ValidateNotNullOrEmpty()][string]$Question,
        [Parameter(Mandatory,Position=1,ValueFromRemainingArguments)][ValidateNotNullOrEmpty()][string[]]$Choices,
        [Parameter()][string]$Model='gpt-6-luna'
    )
    begin {
        $options = [System.Collections.Generic.List[object]]::new()
        $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        foreach ($label in $Choices) {
            if ([string]::IsNullOrWhiteSpace($label)) { throw 'Choice labels cannot be empty or whitespace.' }
            if (-not $seen.Add($label)) { throw "Duplicate choice label '$label'. Labels are case-insensitive." }
            $options.Add([pscustomobject]@{ value=$label; description=$label })
        }
    }
    process {
        $definition = New-OpenAIDecisionQuestion -Type Choice -Name selection -Instructions $Question -Choices @($options)
        $response = Invoke-OpenAIDecision -InputObject $State -Question $definition -Model $Model -ErrorAction Stop
        $answer = Get-OpenAIDecisionAnswer -Response $response -Name selection
        if ($answer.type -eq 'refusal' -or $null -eq $answer.choice) { throw 'OpenAI declined or omitted the choice answer.' }
        $label = [string]$answer.choice
        if (-not $seen.Contains($label)) { throw "OpenAI returned an unknown choice: '$label'." }
        $answer.choice
    }
}
