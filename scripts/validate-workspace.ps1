$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$failures = [System.Collections.Generic.List[string]]::new()

function Require-File {
    param([string]$RelativePath)
    if (-not (Test-Path -LiteralPath (Join-Path $projectRoot $RelativePath) -PathType Leaf)) {
        $failures.Add("Missing required file: $RelativePath")
    }
}

function Require-Text {
    param([string]$RelativePath, [string]$Pattern, [string]$Label)
    $path = Join-Path $projectRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return }
    if ((Get-Content -Raw -Encoding utf8 -LiteralPath $path) -notmatch $Pattern) {
        $failures.Add("$RelativePath lacks $Label")
    }
}

function Require-NotText {
    param([string]$RelativePath, [string]$Pattern, [string]$Label)
    $path = Join-Path $projectRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return }
    if ((Get-Content -Raw -Encoding utf8 -LiteralPath $path) -match $Pattern) {
        $failures.Add("$RelativePath still contains $Label")
    }
}

function Require-MarkdownLinkTarget {
    param([string]$RelativePath, [string]$Target, [string]$Label)
    $path = Join-Path $projectRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return }
    if ((Get-Content -Raw -Encoding utf8 -LiteralPath $path) -notmatch [regex]::Escape($Target)) {
        $failures.Add("$RelativePath lacks link to $Label")
    }
}

@(
    'README.md',
    'README.zh-CN.md',
    'AGENTS.md',
    'CLAUDE.md',
    '.cursor/rules/inspiration-workflow.mdc',
    'instructions/core-workflow.md',
    'instructions/core-workflow.zh-CN.md',
    'ideas/INDEX.md',
    'templates/inspiration-card.en.md',
    'templates/inspiration-card.zh-CN.md'
) | ForEach-Object { Require-File $_ }

Require-Text 'README.md' '(?m)^# Sparkloom\r?$' 'the Sparkloom title'
Require-Text 'README.md' '(?m)^\*Weave ideas into action\.\*\r?$' 'the Sparkloom tagline'
Require-Text 'README.zh-CN.md' '(?m)^# Sparkloom\r?$' 'the Sparkloom title'
Require-Text 'README.zh-CN.md' '(?m)^\*Weave ideas into action\.\*\r?$' 'the Sparkloom tagline'
Require-Text 'AGENTS.md' '(?m)^# Sparkloom for Codex\r?$' 'the Sparkloom Codex heading'
Require-Text 'CLAUDE.md' '(?m)^# Sparkloom for Claude Code\r?$' 'the Sparkloom Claude heading'
Require-Text '.cursor/rules/inspiration-workflow.mdc' '(?m)^# Sparkloom for Cursor\r?$' 'the Sparkloom Cursor heading'
Require-Text 'instructions/core-workflow.md' '(?m)^# Sparkloom Core Workflow\r?$' 'the Sparkloom workflow heading'
Require-Text 'instructions/core-workflow.zh-CN.md' '(?m)^# Sparkloom 核心工作流\r?$' 'the Chinese Sparkloom workflow heading'
Require-Text 'ideas/INDEX.md' '(?m)^# Sparkloom Index / AI 灵感目录\r?$' 'the Sparkloom index heading'

Require-Text 'instructions/core-workflow.md' '## Purpose' 'a purpose section'
Require-Text 'instructions/core-workflow.md' '## Workflow' 'a workflow section'
Require-Text 'instructions/core-workflow.md' '## Card requirements' 'card requirements'
Require-Text 'instructions/core-workflow.md' '## Cross-platform behavior' 'cross-platform behavior'
Require-Text 'instructions/core-workflow.md' '## Fallbacks' 'fallback behavior'
Require-Text 'instructions/core-workflow.zh-CN.md' '## 目标' 'a Chinese purpose section'
Require-Text 'instructions/core-workflow.zh-CN.md' '## 流程' 'a Chinese workflow section'
Require-Text 'instructions/core-workflow.zh-CN.md' '## 卡片要求' 'Chinese card requirements'
Require-Text 'instructions/core-workflow.zh-CN.md' '## 跨工具行为' 'Chinese cross-platform behavior'
Require-Text 'instructions/core-workflow.zh-CN.md' '## 降级' 'Chinese fallback behavior'

Require-MarkdownLinkTarget 'AGENTS.md' 'instructions/core-workflow.md' 'the canonical core workflow'
Require-MarkdownLinkTarget 'CLAUDE.md' 'instructions/core-workflow.md' 'the canonical core workflow'
Require-MarkdownLinkTarget '.cursor/rules/inspiration-workflow.mdc' '../../instructions/core-workflow.md' 'the canonical core workflow'
Require-Text 'AGENTS.md' '\[INSPIRATION_CARD_TASK\]' 'the Codex recursion-prevention marker'

@(
    'instructions/core-workflow.md',
    'instructions/core-workflow.zh-CN.md',
    'AGENTS.md',
    'CLAUDE.md',
    '.cursor/rules/inspiration-workflow.mdc'
) | ForEach-Object {
    Require-NotText $_ '10.?20|3.?5|完整研究报告|full research report' 'the retired fixed-report contract'
}

@('templates/inspiration-card.en.md', 'templates/inspiration-card.zh-CN.md') | ForEach-Object {
    Require-Text $_ 'Related ideas|已有灵感关系' 'a related-ideas section'
    Require-Text $_ 'What to reuse|可复用内容' 'a reusable-content section'
    Require-Text $_ 'Next step|下一步' 'a next-step section'
}

Require-Text 'ideas/INDEX.md' '关联 / Relation' 'a bilingual relation column'
Require-MarkdownLinkTarget 'README.md' 'README.zh-CN.md' 'the Chinese README'
Require-MarkdownLinkTarget 'README.zh-CN.md' 'README.md' 'the English README'

$indexPath = Join-Path $projectRoot 'ideas/INDEX.md'
if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
    $indexText = Get-Content -Raw -Encoding utf8 -LiteralPath $indexPath
    $seenPrimaryTargets = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::OrdinalIgnoreCase
    )

    foreach ($line in ($indexText -split "`r?`n")) {
        if ($line -match '^\|.*\|\s*\[[^\]]+\]\(([^)#]+\.md)(?:#[^)]+)?\)\s*\|\s*$') {
            $primaryTarget = $Matches[1]
            if (-not $seenPrimaryTargets.Add($primaryTarget)) {
                $failures.Add("ideas/INDEX.md contains a duplicate primary card or report link: $primaryTarget")
            }
        }
    }

    foreach ($match in [regex]::Matches($indexText, '\[[^\]]+\]\(([^)#]+\.md)(?:#[^)]+)?\)')) {
        $target = $match.Groups[1].Value
        $targetPath = Join-Path (Split-Path -Parent $indexPath) $target
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
            $failures.Add("ideas/INDEX.md links to a missing report or card: $target")
        }
    }
}

@(
    'AGENTS.md',
    'CLAUDE.md',
    'README.md',
    'README.zh-CN.md',
    'instructions/core-workflow.md',
    'instructions/core-workflow.zh-CN.md',
    'templates/inspiration-card.en.md',
    'templates/inspiration-card.zh-CN.md'
) | ForEach-Object {
    $path = Join-Path $projectRoot $_
    if ((Test-Path -LiteralPath $path -PathType Leaf) -and
        ((Get-Content -Raw -Encoding utf8 -LiteralPath $path) -match '(?im)\b(TBD|TODO)\b|待定|以后补充')) {
        $failures.Add("$_ contains unfinished placeholder text")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { [Console]::Error.WriteLine($_) }
    exit 1
}

Write-Output 'Workspace validation passed.'
exit 0
