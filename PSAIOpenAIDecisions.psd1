@{
    RootModule        = 'PSAIOpenAIDecisions.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '7f2a32b9-14c5-4f4c-91e8-7c355693a2da'
    Author            = 'David Finke'
    Copyright         = '(c) 2026 David Finke'
    Description       = 'A PowerShell client for the OpenAI Decisions API.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @('Invoke-OpenAIDecision', 'New-OpenAIDecisionQuestion', 'New-OpenAIYesNoQuestion', 'Add-OpenAIDecisionAnnotation', 'Add-OpenAIDecisionTag', 'Find-OpenAIDecision', 'Get-OpenAIDecisionChoice', 'Get-OpenAIDecisionRanking', 'Get-OpenAIDecisionScore', 'Select-OpenAIDecision', 'Test-OpenAIDecision')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags          = @('OpenAI', 'Decisions', 'API', 'PowerShell', 'Classification')
            ProjectUri    = 'https://github.com/dfinke/PSAIOpenAIDecisions'
            RepositoryUri = 'https://github.com/dfinke/PSAIOpenAIDecisions'
            LicenseUri    = 'https://github.com/dfinke/PSAIOpenAIDecisions/blob/main/LICENSE'
            ReleaseNotes  = 'Adds PowerShell helpers for predicate, choice, and score questions; pipeline commands for testing, filtering, ranking, choosing, finding, annotating, and tagging inputs; and runnable demonstrations.'
        }
    }
}
