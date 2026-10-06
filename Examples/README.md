# PSAIOpenAIDecisions examples

These examples port the Jev PowerShell workflows to the OpenAI Decisions API.
They use the module in this checkout and make live requests. Set OPENAI_API_KEY
before running an API-backed example.

## Standalone examples

| Example | What it demonstrates |
| --- | --- |
| [Deal desk](DealDesk.ps1) | Compare eligible commercial options and write a review workbook. Requires ImportExcel and data/DealDesk.xlsx. |
| [Excel IT queue](Excel-IT-Queue.ps1) | Rank IT requests by time-sensitive business impact. Requires ImportExcel and data/IT-Operations-Queue.xlsx. |
| [Notes to actions](NotesToActions.ps1) | Classify notes as actions, decisions, or background. |
| [Page on-call](PageOnCall.ps1) | Apply probability thresholds to illustrative incident signals. |
| [PowerShell command finder](PowerShellCommandFinder.ps1) | Select a local command from metadata and display help without executing it. |
| [Quick start](QuickStart.ps1) | Ask predicate, choice, and score questions together. |
| [Refund triage](RefundTriage.ps1) | Evaluate refund intent, request type, and frustration together. |
| [Release notes](ReleaseNotes.ps1) | Categorize recent Git commits and draft release notes. |
| [Security incident triage](SecurityIncidentTriage.ps1) | Summarize predicate, score, and response-choice answers for review. |
| [Semantic log triage](SemanticLogTriage.ps1) | Classify log lines by security risk and likely root cause. |
| [Standup report](StandupReport.ps1) | Categorize recent commits and summarize supplied work and blockers. |

## Pipeline examples

See [Pipelines](Pipelines/README.md) for reply triage, ranking, inbox tagging,
checkout-cause search, request routing, and score-based prioritization.

## Demos

See [Demos](Demos/README.md) for focused examples, local sample data, and
developer quick-hit workflows.
