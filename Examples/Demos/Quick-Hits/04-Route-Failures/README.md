# Route test failures

Give each failure to OpenAI Decisions and ask which component should investigate it. The
choices are deliberately limited to four useful destinations.

```powershell
Import-Module PSAIOpenAIDecisions
Import-Csv .\test-failures.csv | ForEach-Object {
    $failure = $_
    $component = $failure.Message | Get-OpenAIDecisionChoice `
        'Which component should investigate this failure?' api auth database build
    [pscustomobject]@{
        Id        = $failure.Id
        Component = $component
        Failure   = $failure.Message
    }
} | Format-Table -Wrap
```

`Get-OpenAIDecisionChoice` returns one of the supplied labels for each row. Run from this
folder. Each failure is a separate live OpenAI Decisions request, and results can vary.


