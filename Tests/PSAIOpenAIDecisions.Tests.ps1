BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'PSAIOpenAIDecisions.psd1') -Force
}

Describe 'PSAIOpenAIDecisions question builders' {
    BeforeEach {
        $env:OPENAI_API_KEY = 'pester-test-key'
    }

    It 'builds predicate, choice, and score questions with their named fields' {
        $predicate = New-OpenAIYesNoQuestion -Name urgent -Question 'Is this urgent?'
        $choice = New-OpenAIDecisionQuestion -Type Choice -Name route `
            -Instructions 'Where should this go?' -Choices @(
                @{ value = 'billing'; description = 'Payment request' }
                'support'
            )
        $score = New-OpenAIDecisionQuestion -Type Score -Name severity `
            -Instructions 'How severe is this?' -Levels @('Low', 'High')

        $predicate.Type | Should -Be 'Predicate'
        $predicate.Name | Should -Be 'urgent'
        $choice.Choices.Count | Should -Be 2
        $choice.Choices[1].value | Should -Be 'support'
        $score.Levels[0].label | Should -Be 'Low'
    }

    It 'rejects empty choice questions' {
        { New-OpenAIDecisionQuestion -Type Choice -Name route -Instructions 'Where?' -Choices @() } |
            Should -Throw '*Choice questions require*'
    }
}

Describe 'Invoke-OpenAIDecision' {
    BeforeEach {
        $env:OPENAI_API_KEY = 'pester-test-key'
    }

    It 'serializes object input, posts a valid request, and maps named answers' {
        Mock Invoke-RestMethod {
            [pscustomobject]@{
                model   = 'gpt-6-luna'
                answers = @([pscustomobject]@{ type = 'predicate'; name = 'damaged'; probability = 0.93 })
                usage   = [pscustomobject]@{ input_tokens = 12; total_tokens = 12 }
            }
        } -ModuleName PSAIOpenAIDecisions

        $inputObject = [pscustomobject]@{ message = 'The package arrived broken.'; order = 42 }
        $question = New-OpenAIYesNoQuestion -Name damaged -Question 'Is the item damaged?'
        $result = Invoke-OpenAIDecision -InputObject $inputObject -Question $question

        [object]::ReferenceEquals($result.State, $inputObject) | Should -BeTrue
        $result.damaged | Should -Be 0.93
        $result.answers.damaged.probability | Should -Be 0.93
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 1 -Exactly -ParameterFilter {
            $payload = ConvertFrom-Json -InputObject $Body
            $Method -eq 'Post' -and
            $Uri.AbsoluteUri -eq 'https://api.openai.com/v1/decisions' -and
            $payload.model -eq 'gpt-6-luna' -and
            $payload.input -eq '{"message":"The package arrived broken.","order":42}' -and
            $payload.questions[0].type -eq 'predicate' -and
            $payload.questions[0].name -eq 'damaged'
        }
    }

    It 'preserves user message arrays and returns the raw response when requested' {
        Mock Invoke-RestMethod {
            [pscustomobject]@{ model = 'gpt-6-luna'; answers = @(); usage = $null }
        } -ModuleName PSAIOpenAIDecisions

        $messages = @([pscustomobject]@{
                role    = 'user'
                content = @([pscustomobject]@{ type = 'input_text'; text = 'Describe this image.' })
            })
        $question = New-OpenAIYesNoQuestion -Name present -Question 'Is a product visible?'
        $result = Invoke-OpenAIDecision -InputObject $messages -Question $question -Raw

        $result.model | Should -Be 'gpt-6-luna'
        $result.PSObject.Properties.Name | Should -Not -Contain 'State'
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 1 -Exactly -ParameterFilter {
            $payload = ConvertFrom-Json -InputObject $Body
            $payload.input[0].role -eq 'user' -and $payload.input[0].content[0].text -eq 'Describe this image.'
        }
    }

    It 'requires an API key before making a request' {
        Remove-Item Env:OPENAI_API_KEY -ErrorAction SilentlyContinue
        $question = New-OpenAIYesNoQuestion -Name ready -Question 'Is it ready?'

        { Invoke-OpenAIDecision -InputObject 'ready' -Question $question } |
            Should -Throw '*OPENAI_API_KEY is not set*'
    }

    It 'rejects malformed wire questions before making a request' {
        Mock Invoke-RestMethod {} -ModuleName PSAIOpenAIDecisions
        { Invoke-OpenAIDecision -InputObject 'hello' -Questions @(@{ type = 'choice'; name = 'route'; instructions = 'Route it' }) } |
            Should -Throw '*Each choice must have a value*'
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 0 -Exactly
    }
}

Describe 'PSAIOpenAIDecisions pipeline commands' {
    BeforeEach {
        $env:OPENAI_API_KEY = 'pester-test-key'
    }

    It 'tests predicates and keeps only inputs above the threshold' {
        Mock Invoke-RestMethod {
            $payload = ConvertFrom-Json -InputObject $Body
            $probability = if ($payload.input -eq 'urgent') { 0.91 } else { 0.18 }
            [pscustomobject]@{
                model   = 'gpt-6-luna'
                answers = @([pscustomobject]@{ type = 'predicate'; name = 'decision'; probability = $probability })
                usage   = $null
            }
        } -ModuleName PSAIOpenAIDecisions

        Test-OpenAIDecision -State 'urgent' -Question 'Is this urgent?' -Threshold 0.8 | Should -BeTrue
        $selected = @('urgent', 'routine', 'urgent') | Select-OpenAIDecision 'Is this urgent?' -Threshold 0.8
        $selected | Should -Be @('urgent', 'urgent')
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 4 -Exactly
    }

    It 'ranks original inputs by probability and honors Top' {
        Mock Invoke-RestMethod {
            $payload = ConvertFrom-Json -InputObject $Body
            $probability = switch ($payload.input) {
                'first' { 0.5 }
                'second' { 0.9 }
                default { 0.2 }
            }
            [pscustomobject]@{
                model   = 'gpt-6-luna'
                answers = @([pscustomobject]@{ type = 'predicate'; name = 'ranking'; probability = $probability })
                usage   = $null
            }
        } -ModuleName PSAIOpenAIDecisions

        $ranked = @('first', 'second', 'third') | Get-OpenAIDecisionRanking 'Which needs attention?' -Top 2

        $ranked | Should -Be @('second', 'first')
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 3 -Exactly
    }

    It 'returns the selected choice and a numeric score' {
        Mock Invoke-RestMethod {
            $payload = ConvertFrom-Json -InputObject $Body
            if ($payload.questions[0].type -eq 'choice') {
                $answer = [pscustomobject]@{ type = 'choice'; name = 'selection'; choice = 'billing' }
            } else {
                $answer = [pscustomobject]@{ type = 'score'; name = 'rating'; score = 1.4 }
            }
            [pscustomobject]@{ model = 'gpt-6-luna'; answers = @($answer); usage = $null }
        } -ModuleName PSAIOpenAIDecisions

        Get-OpenAIDecisionChoice -State 'duplicate charge' -Question 'Which team?' billing support |
            Should -Be 'billing'
        Get-OpenAIDecisionScore -State 'blocked task' -Question 'How urgent?' low medium high |
            Should -Be 1.4
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 2 -Exactly
    }

    It 'finds the selected original candidate in one request' {
        Mock Invoke-RestMethod {
            [pscustomobject]@{
                model   = 'gpt-6-luna'
                answers = @([pscustomobject]@{ type = 'choice'; name = 'match'; choice = 'candidate0002' })
                usage   = $null
            }
        } -ModuleName PSAIOpenAIDecisions

        $selected = @('unrelated', 'checkout failure', 'other') |
            Find-OpenAIDecision 'Which log explains the checkout failure?'

        $selected | Should -Be 'checkout failure'
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 1 -Exactly
    }

    It 'adds named answers and matching tags without losing input fields' {
        Mock Invoke-RestMethod {
            $payload = ConvertFrom-Json -InputObject $Body
            $answers = foreach ($question in $payload.questions) {
                if ($question.type -eq 'choice') {
                    [pscustomobject]@{ type = 'choice'; name = $question.name; choice = 'billing' }
                } else {
                    $probability = if ($question.name -eq 'urgent') { 0.87 } else { 0.12 }
                    [pscustomobject]@{ type = 'predicate'; name = $question.name; probability = $probability }
                }
            }
            [pscustomobject]@{ model = 'gpt-6-luna'; answers = @($answers); usage = $null }
        } -ModuleName PSAIOpenAIDecisions

        $question = New-OpenAIDecisionQuestion -Type Choice -Name route -Instructions 'Which team?' -Choices @('billing', 'support')
        $annotated = [pscustomobject]@{ Id = 10; Subject = 'Duplicate charge' } |
            Add-OpenAIDecisionAnnotation -Question $question
        $tagged = [pscustomobject]@{ Id = 11; Tags = @('existing'); Subject = 'Urgent invoice issue' } |
            Add-OpenAIDecisionTag -Tags ([ordered]@{ urgent = 'Needs action today.'; account = 'Account access issue.' }) -Threshold 0.8

        $annotated.Id | Should -Be 10
        $annotated.route | Should -Be 'billing'
        $annotated.answers[0].choice | Should -Be 'billing'
        $tagged.Id | Should -Be 11
        $tagged.Tags | Should -Be @('existing')
        $tagged.OpenAIDecision_Tags | Should -Be @('urgent')
        Should -Invoke Invoke-RestMethod -ModuleName PSAIOpenAIDecisions -Times 2 -Exactly
    }
}
