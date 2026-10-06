# OpenAI Decisions PowerShell demos

These focused examples use the OpenAI Decisions API. They use `OPENAI_API_KEY`, make live requests, and include local sample input. Run scripts from any directory; paths are based on each script's location.

| Demo | What it shows |
|---|---|
| [Refund gate](01-refund-gate/README.md) | Use a predicate probability to choose a route. |
| [Route a ticket](02-route-a-ticket/README.md) | Choose a team and apply a probability threshold. |
| [Grep for meaning](03-grep-for-meaning/README.md) | Keep issue reports that meet a semantic threshold. |
| [Top search hits](06-top-search-hits/README.md) | Score passages independently, then sort them. |
| [Find the line](15-find-the-line/README.md) | Compare a bounded set of policy lines in one choice request. |
| [Triage a support queue](16-triage-pipeline/README.md) | Ask predicate, choice, and score questions together. |
| [Rate and sort requests](17-rate-and-sort/README.md) | Score requests on an ordered rubric. |
| [Fail closed on a proposed command](19-no-or-could-not-ask/README.md) | Hold proposals when the answer is no, uncertain, or unavailable. |
| [Choose the next action](21-options-from-the-record/README.md) | Supply different available actions for each workflow step. |
| [Estimate run cost](28-what-a-run-cost/README.md) | Estimate costs from reported token usage and caller-supplied prices. |
| [Inline refund check](Inline-Refund-Check/README.md) | Use a predicate helper in a pipeline. |
| [Test a review stream](Pipelines/TestReviewStream.ps1) | Keep each review beside its Boolean judgment. |
| [Loan approval](Loan-Approval/README.md) | Apply an editable decision policy to validated application objects. |
| [Developer quick hits](Quick-Hits/README.md) | Find, rank, filter, and route build issues. |

These examples demonstrate the API shape and PowerShell workflow; live answers may vary. The Decisions API returns probability/confidence data, and thresholds in the examples are illustrative policies.
