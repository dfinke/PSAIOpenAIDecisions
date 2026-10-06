function Get-OpenAIDecisionAnswer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object]$Response,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Name
    )
    $answers = $Response.answers
    if ($answers -is [System.Collections.IDictionary]) {
        if ($answers.Contains($Name)) { return $answers[$Name] }
    }
    else {
        $matches = @($answers | Where-Object { [string]$_.name -eq $Name })
        if ($matches.Count -eq 1) { return $matches[0] }
        if ($matches.Count -gt 1) { throw "OpenAI returned more than one answer named '$Name'." }
    }
    throw "OpenAI returned no answer named '$Name'."
}
