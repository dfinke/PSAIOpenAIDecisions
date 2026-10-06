function Get-OpenAIDecisionRanking {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$State,
        [Parameter(Mandatory,Position=0)][ValidateNotNullOrEmpty()][string]$Question,
        [Parameter()][ValidateRange(1,[int]::MaxValue)][int]$Top,
        [Parameter()][string]$Model='gpt-6-luna'
    )
    begin { $ranked = [System.Collections.Generic.List[object]]::new() }
    process {
        $definition = New-OpenAIYesNoQuestion -Name ranking -Question $Question
        $response = Invoke-OpenAIDecision -InputObject $State -Question $definition -Model $Model -ErrorAction Stop
        $answer = Get-OpenAIDecisionAnswer -Response $response -Name ranking
        if ($answer.type -eq 'refusal' -or $null -eq $answer.probability) { throw 'OpenAI declined or omitted a ranking answer.' }
        $ranked.Add([pscustomobject]@{ State=$State; Probability=[double]$answer.probability })
    }
    end {
        $ordered = $ranked | Sort-Object -Property Probability -Descending -Stable
        if ($PSBoundParameters.ContainsKey('Top')) { $ordered = $ordered | Select-Object -First $Top }
        foreach ($item in $ordered) { $PSCmdlet.WriteObject($item.State,$false) }
    }
}
