# Inline refund check

Pipe a customer message into `Test-OpenAIDecision` and print a Boolean result for a yes/no question.

With PowerShell 7 and `OPENAI_API_KEY` configured, run from the repository root:

```powershell
.\Examples\Demos\Inline-Refund-Check\InlineRefundCheck.ps1
# True
```

`Test-OpenAIDecision` asks a predicate question and compares OpenAI Decisions's yes probability with `0.5`, outputting only `True` or `False`. Pass the question as the first positional argument; an optional second argument sets the threshold. That Boolean can go straight into an `if` statement or another PowerShell pipeline. Each input makes a live request, so the result can vary.

Request errors stop the script.


