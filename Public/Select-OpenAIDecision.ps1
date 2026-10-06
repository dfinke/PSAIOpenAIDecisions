function Select-OpenAIDecision {
    [CmdletBinding(PositionalBinding=$false)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)][object]$State,
        [Parameter(Mandatory,Position=0)][ValidateNotNullOrEmpty()][string]$Question,
        [Parameter(Position=1)][ValidateRange(0.0,1.0)][double]$Threshold=0.5,
        [Parameter()][string]$Model='gpt-6-luna'
    )
    process {
        if (Test-OpenAIDecision -State $State -Question $Question -Threshold $Threshold -Model $Model) { $PSCmdlet.WriteObject($State,$false) }
    }
}
