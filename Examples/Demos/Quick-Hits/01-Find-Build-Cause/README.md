# Find the build cause

Ask OpenAI Decisions to choose the line that best explains why the build failed. The log
includes successful steps, warnings, and a downstream error so the cause is
not simply the first line containing the word `error`.

```powershell
Import-Module PSAIOpenAIDecisions
Get-Content .\build.log | Find-OpenAIDecision 'Which line best explains why the build failed?'
```

`Find-OpenAIDecision` compares the candidate lines together in one OpenAI Decisions request and returns
the selected original line. Run from this folder. Results can vary between
live requests.


