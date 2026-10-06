<#
.SYNOPSIS
    Evaluates one or more ordered questions against shared input.
.DESCRIPTION
    Sends a request to POST /v1/decisions. Input can be text or user messages
    containing text and inline data-URL images. By default, named answers are
    also exposed through an answers map and as top-level properties. Use -Raw
    to return the unmodified API response.
#>
function Invoke-OpenAIDecision {
    [CmdletBinding(DefaultParameterSetName='QuestionObjects')]
    param(
        [Parameter(Mandatory,Position=0,ValueFromPipeline)][Alias('Input')][ValidateNotNull()][object]$InputObject,
        [Parameter(Mandatory,ParameterSetName='QuestionObjects')][ValidateNotNullOrEmpty()][object[]]$Question,
        [Parameter(Mandatory,ParameterSetName='WireQuestions')][ValidateNotNullOrEmpty()][object[]]$Questions,
        [Parameter()][ValidateNotNullOrEmpty()][string]$Model='gpt-6-luna',
        [Parameter()][ValidateNotNullOrEmpty()][uri]$Endpoint='https://api.openai.com/v1/decisions',
        [Parameter()][ValidateRange(1,600)][int]$TimeoutSec=30,
        [Parameter()][ValidateLength(1,128)][string]$SafetyIdentifier,
        [Parameter()][switch]$Raw
    )
    process {
        if ([string]::IsNullOrWhiteSpace([string]$env:OPENAI_API_KEY)) {
            throw [System.InvalidOperationException]::new('OPENAI_API_KEY is not set. Set it in the environment before calling this command.')
        }

        if ($PSCmdlet.ParameterSetName -eq 'QuestionObjects') { $wireQuestions = @(ConvertTo-OpenAIDecisionQuestion -Question $Question) }
        else { $wireQuestions = @($Questions) }
        Assert-OpenAIDecisionQuestions -Questions $wireQuestions

        $payload = [ordered]@{ model=$Model; input=$InputObject; questions=$wireQuestions }
        if (-not [string]::IsNullOrWhiteSpace($SafetyIdentifier)) { $payload.safety_identifier=$SafetyIdentifier }
        $requestBody = ConvertTo-Json -InputObject $payload -Depth 100 -Compress
        $headers = @{ Authorization = "Bearer $env:OPENAI_API_KEY" }
        try {
            $response = Invoke-RestMethod -Uri $Endpoint -Method Post -Headers $headers -ContentType 'application/json' -Body $requestBody -TimeoutSec $TimeoutSec -ErrorAction Stop
        }
        catch {
            $details = Get-OpenAIDecisionErrorDetails -ErrorRecord $_
            throw "OpenAI Decisions request failed at '$Endpoint': $details"
        }
        if ($Raw) { $PSCmdlet.WriteObject($response,$false); return }

        $namedAnswers = [ordered]@{}
        foreach ($answer in @($response.answers)) {
            if ($null -ne $answer.name -and -not [string]::IsNullOrWhiteSpace([string]$answer.name)) { $namedAnswers[[string]$answer.name]=$answer }
        }
        $result = [ordered]@{ State=$InputObject; Model=$response.model; answers=$namedAnswers; usage=$response.usage }
        foreach ($answerName in $namedAnswers.Keys) {
            $answer = $namedAnswers[$answerName]
            $value = switch ([string]$answer.type) {
                'predicate' { $answer.probability }
                'choice' { $answer.choice }
                'score' { $answer.score }
                default { $answer }
            }
            if (-not $result.Contains($answerName)) { $result[$answerName]=$value }
        }
        $PSCmdlet.WriteObject([pscustomobject]$result,$false)
    }
}
