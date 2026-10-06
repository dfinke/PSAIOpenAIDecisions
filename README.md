# PSAIOpenAIDecisions

A PowerShell module for OpenAI's Decisions API. Build predicate, choice, and score questions, invoke the API, and use pipeline commands to filter, rank, choose, or find original PowerShell inputs.

Set `OPENAI_API_KEY` before making live requests. The module uses `POST https://api.openai.com/v1/decisions` and defaults to `gpt-6-luna`.

## Quick start

```powershell
Import-Module PSAIOpenAIDecisions

$question = New-OpenAIYesNoQuestion -Name damaged `
    -Question 'Does the customer report a damaged item?'

$response = Invoke-OpenAIDecision `
    -Input 'The package arrived with a broken screen.' `
    -Question $question

$response.damaged
$response.answers.damaged.probability
```

`Invoke-OpenAIDecision` returns the API metadata, a named `answers` map, and convenient top-level answer values. Use `-Raw` to get the unmodified API response, whose answers remain in question order. The command accepts text, PowerShell records (sent as JSON text), or supported user messages with inline image data URLs.

## Question types

```powershell
$questions = @(
    New-OpenAIYesNoQuestion -Name damaged -Question 'Does the customer report a damaged item?'
    New-OpenAIDecisionQuestion -Type Choice -Name route `
        -Instructions 'Which team should handle this request?' `
        -Choices @(
            @{ value = 'billing'; description = 'Charges, invoices, refunds, or payments' }
            @{ value = 'technical'; description = 'Product bugs or integration failures' }
            @{ value = 'account'; description = 'Login or account access' }
        )
    New-OpenAIDecisionQuestion -Type Score -Name urgency `
        -Instructions 'How urgent is this request?' `
        -Levels @('Can wait', 'Needs attention soon', 'Urgent')
)
Invoke-OpenAIDecision -Input 'I was charged twice and cannot sign in.' -Question $questions
```

`Choice` values may be strings or Booleans. Provide descriptions when they help distinguish options. `Score` levels are ordered from lowest to highest. For migration convenience, `-Type Noul` and `-Criteria` choice maps or score arrays are also accepted; questions are translated to OpenAI's predicate, choices, and levels schema.

## Pipeline commands

- `Test-OpenAIDecision` returns whether a predicate probability meets a threshold.
- `Select-OpenAIDecision` keeps the original inputs that meet a threshold.
- `Get-OpenAIDecisionRanking` returns original inputs ordered by predicate probability.
- `Get-OpenAIDecisionChoice` chooses one supplied string label per input.
- `Find-OpenAIDecision` compares candidates together and returns the selected original input, or no output if `none` is selected.
- `Add-OpenAIDecisionAnnotation` adds named answers while retaining each input.
- `Add-OpenAIDecisionTag` applies multiple independent predicate tags in one request per input.
- `Get-OpenAIDecisionScore` returns a numeric score on caller-supplied ordered levels.

Each pipeline item makes a live API request, except `Find-OpenAIDecision`, which compares its finite input set in one choice request. Thresholds are caller policy; inspect the probabilities and route uncertain answers for review when appropriate.

## Examples

- [Simple decision](Examples/SimpleDecision.ps1)
- [Complete example index](Examples/README.md), including standalone example ports, pipeline workflows, and focused demos.

Install the current checkout with `./InstallModule.ps1`. For request and answer schemas, see the [OpenAI Decisions API reference](https://developers.openai.com/api/reference/resources/decisions/methods/create).

## License

MIT. See [LICENSE](LICENSE).

