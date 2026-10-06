<#
.SYNOPSIS
    Evaluates ordered questions against shared input with the OpenAI Decisions API.
.DESCRIPTION
    Sends one request to POST /v1/decisions. Input can be text or user messages
    containing text and inline data-URL images. The command returns the parsed
    API response without reshaping it.
#>
function Invoke-OpenAIDecision {
    [CmdletBinding(DefaultParameterSetName='QuestionObjects')]
    param(
        [Parameter(Mandatory, Position=0)][Alias('Input')][ValidateNotNull()][object]$InputObject,
        [Parameter(Mandatory, ParameterSetName='QuestionObjects')][ValidateNotNullOrEmpty()][object[]]$Question,
        [Parameter(Mandatory, ParameterSetName='WireQuestions')][ValidateNotNullOrEmpty()][object[]]$Questions,
        [Parameter()][ValidateNotNullOrEmpty()][string]$Model = 'gpt-6-luna',
        [Parameter()][ValidateNotNullOrEmpty()][uri]$Endpoint = 'https://api.openai.com/v1/decisions',
        [Parameter()][ValidateRange(1,600)][int]$TimeoutSec = 30,
        [Parameter()][ValidateLength(1,128)][string]$SafetyIdentifier
    )

    if ([string]::IsNullOrWhiteSpace([string]$env:OPENAI_API_KEY)) {
        throw [System.InvalidOperationException]::new('OPENAI_API_KEY is not set. Set it in the environment before calling this command.')
    }

    if ($PSCmdlet.ParameterSetName -eq 'QuestionObjects') {
        $wireQuestions = @(ConvertTo-OpenAIDecisionQuestion -Question $Question)
    } else {
        $wireQuestions = @($Questions)
    }
    Assert-OpenAIDecisionQuestions -Questions $wireQuestions

    $payload = [ordered]@{ model = $Model; input = $InputObject; questions = $wireQuestions }
    if (-not [string]::IsNullOrWhiteSpace($SafetyIdentifier)) { $payload.safety_identifier = $SafetyIdentifier }
    $requestBody = ConvertTo-Json -InputObject $payload -Depth 100 -Compress
    $headers = @{ Authorization = "Bearer $env:OPENAI_API_KEY" }

    try {
        Invoke-RestMethod -Uri $Endpoint -Method Post -Headers $headers -ContentType 'application/json' -Body $requestBody -TimeoutSec $TimeoutSec -ErrorAction Stop
    }
    catch {
        $details = Get-OpenAIDecisionErrorDetails -ErrorRecord $_
        throw "OpenAI Decisions request failed at '$Endpoint': $details"
    }
}
