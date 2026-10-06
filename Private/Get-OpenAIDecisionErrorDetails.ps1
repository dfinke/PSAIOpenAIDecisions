function Get-OpenAIDecisionErrorDetails {
    [CmdletBinding()]
    param([Parameter(Mandatory)][System.Management.Automation.ErrorRecord]$ErrorRecord)

    $statusCode = $null
    try { $statusCode = [int]$ErrorRecord.Exception.Response.StatusCode } catch { }
    $message = $ErrorRecord.ErrorDetails.Message
    if ([string]::IsNullOrWhiteSpace($message)) { $message = $ErrorRecord.Exception.Message }
    if ($null -ne $statusCode -and $statusCode -gt 0) { return "HTTP $statusCode. $message" }
    return $message
}
