# Rank build clues

Ask for the three lines that best explain why the release build failed. This
file contains incidental activity as well as symptoms and a likely cause.

```powershell
Import-Module PSAIOpenAIDecisions
Get-Content .\release-build.log |
    Get-OpenAIDecisionRanking 'Which lines best explain why the release build failed?' -Top 3
```

`Get-OpenAIDecisionRanking` evaluates each line, then returns the top three original lines.
That means one OpenAI Decisions request per line. Run from this folder. Results can vary
between live requests.


