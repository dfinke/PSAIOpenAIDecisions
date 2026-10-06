# PSAIOpenAIDecisions

A PowerShell module for the OpenAI Decisions API. It submits text or supported user messages and returns structured answers to ordered predicate, choice, and score questions.

## Quick start

Set `OPENAI_API_KEY`, then import the module and send a decision:

```powershell
Import-Module PSAIOpenAIDecisions

$questions = @(
    New-OpenAIYesNoQuestion -Name damaged -Instructions 'Does the customer report a damaged item?'
    New-OpenAIDecisionQuestion -Type Choice -Name route `
        -Instructions 'Which team should handle this request?' `
        -Choices @(
            @{ value = 'billing'; description = 'Charges, invoices, refunds, or payment processing' }
            @{ value = 'technical'; description = 'Product bugs, outages, or integration failures' }
            @{ value = 'account'; description = 'Login, permissions, or profile access' }
        )
    New-OpenAIDecisionQuestion -Type Score -Name urgency `
        -Instructions 'How urgent is this request?' `
        -Levels @('Can wait', 'Needs attention soon', 'Urgent')
)

$response = Invoke-OpenAIDecision -Input 'The package arrived with a broken screen.' -Question $questions
$response.answers | Format-List
```

`Invoke-OpenAIDecision` makes one request to `POST https://api.openai.com/v1/decisions` and returns the API response as received. `-Question` accepts helper objects. `-Questions` accepts question objects already in the documented API shape. The model defaults to `gpt-6-luna`; use `-Model` to select another model available to your account. `-TimeoutSec` defaults to 30 seconds. An optional `-SafetyIdentifier` is sent as `safety_identifier`.

## Questions

- `Predicate`: asks whether a statement is true; the answer includes its probability.
- `Choice`: pass `-Choices` as strings or as objects with `value` and optional `description`. Values may be strings or Booleans.
- `Score`: pass `-Levels` as ordered labels or objects with `label` and optional `description`.

The question order is preserved in the request and the answer array. The API may return a `refusal` answer for a question. Read the OpenAI API reference for the current schema and limits.

## Input

Input may be a string or an array of user messages. Message content may contain text and inline images as data URLs. External image URLs, file IDs, audio, and non-user messages are not supported by this endpoint. See the [Decisions API reference](https://developers.openai.com/api/reference/resources/decisions/methods/create).

```powershell
$input = @(
    @{
        role = 'user'
        content = @(
            @{ type = 'input_text'; text = 'Does this item appear damaged?' }
            @{ type = 'input_image'; image_url = 'data:image/jpeg;base64,...' }
        )
    }
)
Invoke-OpenAIDecision -Input $input -Question $questions[0]
```

## Install from this checkout

```powershell
./InstallModule.ps1
```

## License

MIT. See [LICENSE](LICENSE).
