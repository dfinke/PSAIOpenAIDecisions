function Test-OpenAIDecision {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$State,
        [Parameter(Mandatory,Position=0)][ValidateNotNullOrEmpty()][string]$Question,
        [Parameter(Position=1)][ValidateRange(0.0,1.0)][double]$Threshold=0.5,
        [Parameter()][string]$Model='gpt-6-luna'
    )
    process {
        $definition = New-OpenAIYesNoQuestion -Name decision -Question $Question
        $response = Invoke-OpenAIDecision -InputObject $State -Question $definition -Model $Model -ErrorAction Stop
        $answer = Get-OpenAIDecisionAnswer -Response $response -Name decision
        if ($answer.type -eq 'refusal' -or $null -eq $answer.probability) { throw 'OpenAI declined or omitted the predicate answer.' }
        $probability = [double]$answer.probability
        if ([double]::IsNaN($probability) -or $probability -lt 0 -or $probability -gt 1) { throw 'OpenAI returned a predicate probability outside the range 0 to 1.' }
        $probability -ge $Threshold
    }
}
