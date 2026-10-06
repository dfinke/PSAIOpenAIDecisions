# Pipe a customer message to Test-OpenAIDecision and print its Boolean result.
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../../../PSAIOpenAIDecisions.psd1"

@'
I renewed once this morning, but my card shows two charges.
Please refund the duplicate.
'@ | Test-OpenAIDecision 'Does the customer ask for a refund?'


