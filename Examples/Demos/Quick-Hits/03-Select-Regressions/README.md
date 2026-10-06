# Select user-visible failures

Keep test output that points to a user-visible regression. Passing tests,
environment warnings, and internal diagnostic noise give OpenAI Decisions useful contrast.

```powershell
Import-Module PSAIOpenAIDecisions
Get-Content .\test-output.txt |
    Select-OpenAIDecision 'Which test results indicate a user-visible regression?'
```

`Select-OpenAIDecision` returns the original lines it judges relevant. Run from this
folder. Each line is evaluated separately, so this short file makes a small
number of live requests. Results can vary between runs.


