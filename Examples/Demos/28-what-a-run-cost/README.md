# Estimate what a run cost

OpenAI Decisions returns token usage with each answer. This example estimates a run's cost using prices you provide; it does not assume a published rate or infer your account pricing.

With PowerShell 7 and `OPENAI_API_KEY` configured, pass the applicable input and output prices per million tokens:

```powershell
$run = .\Examples\Demos\28-what-a-run-cost\EstimateRunCost.ps1 `
    -InputPricePerMillionTokens 1.00 `
    -OutputPricePerMillionTokens 0.00

$run.Rows | Format-Table Id, Specialist, InputTokens, OutputTokens, EstimatedUsd
$run.Summary | Format-List
```

Replace the sample prices with the rates that apply to your account and model. The script reads `usage.input_tokens` and `usage.output_tokens` for each request and applies:

```text
(input tokens × input price + output tokens × output price) ÷ 1,000,000
```

If a response has no usage values, its ID appears in `MissingUsageIds` and its cost is left blank. The summary totals only requests with reported usage. This is an estimate, not an invoice or spending cap; each run makes new live requests.
