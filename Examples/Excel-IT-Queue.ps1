#requires -Modules ImportExcel

Import-Module (Join-Path $PSScriptRoot '..' 'PSAIOpenAIDecisions.psd1') -Force

$xlsx = "$PSScriptRoot\..\data\IT-Operations-Queue.xlsx"
$question = New-OpenAIYesNoQuestion -Name decision -Question 'Which request should IT investigate today because waiting could disrupt a time-sensitive business process?'

$results = foreach ($request in Import-Excel $xlsx -WorksheetName 'IT Queue') {
    $response = Invoke-OpenAIDecision -InputObject $request -Question $question
    [pscustomobject]@{
        Ticket        = $request.Ticket
        Service       = $request.Service
        UsersAffected = $request.UsersAffected
        Deadline      = $request.Deadline
        decision      = [double]$response.answers.decision.probability
    }
}

$results | Sort-Object decision -Descending |
    Format-Table Ticket, Service, UsersAffected, Deadline, decision -AutoSize
