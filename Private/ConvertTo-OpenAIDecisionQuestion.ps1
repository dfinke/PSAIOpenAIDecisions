function ConvertTo-OpenAIDecisionQuestion {
    [CmdletBinding()]
    param([Parameter(Mandatory)][object[]]$Question)

    foreach ($item in $Question) {
        if ($null -eq $item -or $null -eq $item.PSObject.Properties['Type'] -or $null -eq $item.PSObject.Properties['Instructions']) {
            throw 'Each Question must be created with New-OpenAIDecisionQuestion or New-OpenAIYesNoQuestion.'
        }
        $type = ([string]$item.Type).ToLowerInvariant()
        $wire = [ordered]@{ type = $type; instructions = $item.Instructions }
        if (-not [string]::IsNullOrWhiteSpace([string]$item.Name)) { $wire.name = [string]$item.Name }
        if ($type -eq 'choice') { $wire.choices = @($item.Choices) }
        if ($type -eq 'score') { $wire.levels = @($item.Levels) }
        [pscustomobject]$wire
    }
}
