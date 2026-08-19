# Cross-Tool Lightweight Inspiration Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn Inspiration into a bilingual, cross-tool workspace that saves lightweight inspiration cards instead of mandatory long research reports.

**Architecture:** Keep one canonical English workflow in `instructions/core-workflow.md`. Codex, Claude Code, and Cursor each load that file through a thin platform adapter, while user-facing guidance and card templates are available in English and Chinese. The existing `ideas/INDEX.md` remains the single source of truth, gains a relation field, and retains all existing report links unchanged.

**Tech Stack:** Markdown, PowerShell, Git; no runtime dependencies.

## Global Constraints

- Support Codex, Claude Code, and Cursor without claiming a capability that a platform does not provide.
- `instructions/core-workflow.md` is the normative workflow; the Chinese file is its complete user-facing counterpart.
- New ideas use a short card, not a fixed-size research report or a mandated candidate count.
- Every new card retains related-idea, reusable-content, and next-step sections.
- Preserve all existing files in `ideas/`; do not convert or rewrite the three historic reports.
- Keep `ideas/INDEX.md` as one bilingual index, not parallel English and Chinese indexes.
- Do not add a database, a vector store, a web application, or external dependencies.
- Do not commit while repository-local `user.name` and `user.email` are absent, or while unrelated staged work has not been reviewed.

---

## File Map

| Path | Action | Responsibility |
|---|---|---|
| `scripts/validate-workspace.ps1` | Modify | Validate the new cross-tool, bilingual, lightweight-card contract. |
| `instructions/core-workflow.md` | Create | Canonical English behavior for every supported agent. |
| `instructions/core-workflow.zh-CN.md` | Create | Complete Chinese counterpart of the core workflow. |
| `AGENTS.md` | Modify | Thin Codex adapter and Codex-specific task-isolation fallback. |
| `CLAUDE.md` | Create | Thin Claude Code adapter and its fallback behavior. |
| `.cursor/rules/inspiration-workflow.mdc` | Create | Thin always-applied Cursor rule and its fallback behavior. |
| `templates/inspiration-card.en.md` | Create | English lightweight-card schema. |
| `templates/inspiration-card.zh-CN.md` | Create | Chinese lightweight-card schema. |
| `ideas/INDEX.md` | Modify | One bilingual catalog with relation links and preserved historical rows. |
| `README.md` | Modify | English project overview and setup guide. |
| `README.zh-CN.md` | Create | Chinese project overview and setup guide. |

## Task 1: Replace the Static Contract Check

**Files:**

- Modify: `scripts/validate-workspace.ps1`

**Interfaces:**

- Consumes: the repository root and Markdown files in the file map.
- Produces: exit code `0` plus `Workspace validation passed.` only when the cross-tool lightweight-card contract is complete.

- [ ] **Step 1: Replace the old report-oriented requirements with a failing new contract**

Replace the existing required-file array and all old `10–20`, `3–5`, and report-heading assertions with the following structural checks. Keep `Require-File` and `Require-Text`, then add `Require-NotText` and `Require-MarkdownLinkTarget`.

```powershell
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
```

Add the following exact content assertions after the required-file checks:

```powershell
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

@('instructions/core-workflow.md','instructions/core-workflow.zh-CN.md','AGENTS.md','CLAUDE.md','.cursor/rules/inspiration-workflow.mdc') |
    ForEach-Object {
        Require-NotText $_ '10.?20|3.?5|完整研究报告|full research report' 'the retired fixed-report contract'
    }

@('templates/inspiration-card.en.md','templates/inspiration-card.zh-CN.md') |
    ForEach-Object {
        Require-Text $_ 'Related ideas|已有灵感关系' 'a related-ideas section'
        Require-Text $_ 'What to reuse|可复用内容' 'a reusable-content section'
        Require-Text $_ 'Next step|下一步' 'a next-step section'
    }

Require-Text 'ideas/INDEX.md' '关联 / Relation' 'a bilingual relation column'
Require-MarkdownLinkTarget 'README.md' 'README.zh-CN.md' 'the Chinese README'
Require-MarkdownLinkTarget 'README.zh-CN.md' 'README.md' 'the English README'
```

Add an index-link loop before the final failure check. It validates relative Markdown links ending in `.md` and ignores external URLs and anchors.

```powershell
$indexPath = Join-Path $projectRoot 'ideas/INDEX.md'
if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
    $indexText = Get-Content -Raw -Encoding utf8 -LiteralPath $indexPath
    $seenPrimaryTargets = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
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
        if (-not (Test-Path -LiteralPath (Join-Path (Split-Path -Parent $indexPath) $target) -PathType Leaf)) {
            $failures.Add("ideas/INDEX.md links to a missing report or card: $target")
        }
    }
}
```

- [ ] **Step 2: Run the validator before creating the new contract files**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit code `1`, naming the missing bilingual README, adapters, core workflow files, and card templates. It must not require a fixed candidate count or the old report template.

- [ ] **Step 3: Inspect the check for false positives**

Run:

```powershell
Select-String -LiteralPath .\scripts\validate-workspace.ps1 -Pattern '10.?20|3.?5|完整研究报告|full research report'
```

Expected: matches occur only inside the retired-contract rejection check, not inside a positive requirement.

- [ ] **Step 4: Check whitespace and preserve existing staging**

Run:

```powershell
git diff --check
git status --short
```

Expected: no whitespace error. Do not commit or alter pre-existing staged files.

## Task 2: Add the Canonical Workflow and Platform Adapters

**Files:**

- Create: `instructions/core-workflow.md`
- Create: `instructions/core-workflow.zh-CN.md`
- Modify: `AGENTS.md`
- Create: `CLAUDE.md`
- Create: `.cursor/rules/inspiration-workflow.mdc`

**Interfaces:**

- Consumes: the validator contract from Task 1.
- Produces: one normative workflow and three narrow platform entry points.

- [ ] **Step 1: Write the canonical English core workflow**

Create `instructions/core-workflow.md` with these sections and rules:

```markdown
# Inspiration Core Workflow

## Purpose

Capture AI-workflow ideas, check existing related work, record reusable parts, and choose a small next step. Store each new idea as one lightweight Markdown card.

## Workflow

1. Classify the input as a new idea, an addition, a variant, or ordinary discussion.
2. Before external searching, inspect `ideas/INDEX.md` and relevant existing cards.
3. Record the relation as duplicate, variant, complementary, dependency, or no clear relation.
4. Ask one clarifying question only when the answer changes the search direction.
5. Search only as much as needed for 1–3 relevant GitHub projects, products, or sources.
6. Record reusable skills, agents, MCP servers, prompts, scripts, data sources, or design patterns.
7. Create or update one card and its index row.

## Card requirements

Choose the card template matching the user's language. Every new card keeps Related ideas, What to reuse, and Next step. Do not create a duplicated second-language card for the same idea.

## Cross-platform behavior

Read the platform adapter before acting. Never claim that a platform can create independent chats or tasks when it cannot. Use an independent task when the platform supports it; otherwise use a separate card file to isolate the idea.

## Fallbacks

If existing cards cannot be read, note that the relation check was unavailable and continue. If external search is unavailable, record that limitation and do not present unverified model memory as a checked source. Preserve incomplete cards with a paused status.
```

- [ ] **Step 2: Create the complete Chinese counterpart**

Create `instructions/core-workflow.zh-CN.md` exactly as follows:

```markdown
# Inspiration 核心工作流

## 目标

记录 AI 工作流灵感，检查已有相关方案，标记可复用部分，并确定一个最小下一步。每条新灵感只保存为一张轻量 Markdown 卡片。

## 流程

1. 判断输入是新灵感、已有灵感补充、变体还是普通讨论。
2. 外部搜索前，先检查 `ideas/INDEX.md` 和相关已有卡片。
3. 将关系记录为重复、变体、互补、依赖或无明显关联。
4. 只有答案会改变检索方向时，才一次询问一个澄清问题。
5. 按需搜索 1–3 个相关 GitHub 项目、产品或资料。
6. 记录可复用的 Skill、Agent、MCP、Prompt、脚本、数据源或设计模式。
7. 创建或更新一张卡片及其索引行。

## 卡片要求

根据用户语言选择卡片模板。每张新卡片必须保留“已有灵感关系”“可复用内容”和“下一步”。同一灵感不得再生成一张内容重复的第二语言卡片。

## 跨工具行为

执行前先读取平台适配器。不得声称平台拥有实际不存在的独立聊天或任务创建能力。平台支持时使用独立任务；不支持时通过独立卡片文件隔离灵感。

## 降级

无法读取已有卡片时，记录关系检查未完成并继续。无法外部搜索时，记录渠道限制，不得把未经验证的模型记忆写成已核验来源。研究中断时保留卡片并设为暂停状态。
```

- [ ] **Step 3: Replace `AGENTS.md` with a thin Codex adapter**

Use this structure:

```markdown
# Inspiration for Codex

Read and follow the [canonical core workflow](instructions/core-workflow.md) before handling an inspiration.

## Codex behavior

- If the initial message contains `[INSPIRATION_CARD_TASK]`, handle that seeded idea in the current task and do not create another task for it.
- For a clear new idea, create an independent Codex task when the current environment provides task creation.
- Pass `[INSPIRATION_CARD_TASK]`, the original user wording, current date, and intended card path to that task.
- If task creation is unavailable, research in the current task and save the independent card instead.
```

- [ ] **Step 4: Create the Claude Code adapter**

Create `CLAUDE.md` with a canonical-core link and these platform rules:

```markdown
# Inspiration for Claude Code

Read and follow the [canonical core workflow](instructions/core-workflow.md) before handling an inspiration.

## Claude Code behavior

- Use a dedicated task or new conversation only when the available environment supports it.
- Otherwise keep the conversation focused on one idea and isolate it with a separate card file.
- Do not claim automatic chat creation or a task-management capability unless it is available in the active environment.
```

- [ ] **Step 5: Create the Cursor rule**

Create `.cursor/rules/inspiration-workflow.mdc`:

```markdown
---
description: Lightweight cross-tool workflow for AI inspiration cards
alwaysApply: true
---

# Inspiration for Cursor

Read and follow the [canonical core workflow](../../instructions/core-workflow.md) before handling an inspiration.

## Cursor behavior

- Work in the current chat by default.
- Use one independent card file per idea to isolate context.
- Do not claim that Cursor automatically creates independent chats or tasks.
```

- [ ] **Step 6: Run the validator and inspect adapter scope**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
Get-Content .\AGENTS.md, .\CLAUDE.md, .\.cursor\rules\inspiration-workflow.mdc
```

Expected: the validator still fails only for the files intentionally deferred to Tasks 3–4; each adapter is short, links to the core, and contains no copied full workflow.

## Task 3: Introduce Lightweight Cards and the Single Bilingual Index

**Files:**

- Create: `templates/inspiration-card.en.md`
- Create: `templates/inspiration-card.zh-CN.md`
- Modify: `ideas/INDEX.md`

**Interfaces:**

- Consumes: the card requirements in the canonical workflow.
- Produces: one-language-per-idea cards and an index that preserves historical reports.

- [ ] **Step 1: Create the English card template**

Create `templates/inspiration-card.en.md` exactly as follows:

```markdown
# <Idea title>

- Date: <YYYY-MM-DD>
- Status: queued
- One-line idea: <one sentence>

## Related ideas

- Relation: duplicate, variant, complementary, dependency, or no clear relation
- Related cards: <relative links or none>

## Similar references

- Reference: <GitHub project, product, or source>
- Why it matters: <one short sentence>

## What to reuse

- Reuse directly: <skills, agents, MCP servers, prompts, scripts, data, or patterns>
- Adapt or build: <what cannot be reused as-is>
- Risks: <license, privacy, maintenance, or reliability risks>

## Next step

- Smallest action: <one observable action>
- Success signal: <what would make this worth continuing>
```

- [ ] **Step 2: Create the matching Chinese card template**

Create `templates/inspiration-card.zh-CN.md` with identical fields in Chinese:

```markdown
# <灵感名称>

- 日期：<YYYY-MM-DD>
- 状态：待处理 / queued
- 一句话想法：<一句话>

## 已有灵感关系

- 关系：重复、变体、互补、依赖或无明显关联
- 关联卡片：<相对链接或无>

## 外部参考

- 参考：<GitHub 项目、产品或资料>
- 相关原因：<一句话>

## 可复用内容

- 可直接复用：<Skill、Agent、MCP、Prompt、脚本、数据或模式>
- 需要改造或自行实现：<不能直接复用的部分>
- 风险：<许可证、隐私、维护或稳定性风险>

## 下一步

- 最小行动：<一个可观察的动作>
- 成功信号：<什么结果值得继续>
```

- [ ] **Step 3: Convert the index schema without rewriting historical reports**

Replace the header and table header in `ideas/INDEX.md` with:

```markdown
# Inspiration Index / AI 灵感目录

One row per idea card or historical report. Status values: queued / 待处理, active / 进行中, completed / 已完成, paused / 暂停.

| Idea / 灵感名称 | Date / 日期 | One-line idea / 一句话想法 | Status / 状态 | Relation / 关联 | Card or report / 卡片或报告 |
|---|---|---|---|---|---|
```

Keep the three existing rows and their links. Translate their status cells to `completed / 已完成`, set the relation cell to `—`, and retain each original Chinese description and relative report path.

- [ ] **Step 4: Run the validator and test the existing index links**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
Get-Content .\ideas\INDEX.md
```

Expected: the validator still fails only for missing bilingual README files. Historical report links continue to resolve; the index has six columns.

## Task 4: Publish Bilingual User-Facing Documentation

**Files:**

- Modify: `README.md`
- Create: `README.zh-CN.md`

**Interfaces:**

- Consumes: all paths and behavior created by Tasks 1–3.
- Produces: equivalent English and Chinese onboarding documentation that links to each other and accurately states platform limitations.

- [ ] **Step 1: Replace `README.md` with the English guide**

Document all of the following in this order:

1. A one-paragraph positioning statement: a lightweight cross-tool prior-art workspace for AI workflow ideas.
2. A direct link to `README.zh-CN.md`.
3. Supported tools: Codex, Claude Code, Cursor.
4. The four-card outcome: idea, related ideas, reusable parts, next step.
5. A short flow: say an idea naturally, check existing cards, save a card, revisit the index.
6. A clear platform behavior table: Codex may create an independent task where available; Claude Code and Cursor use a separate card file when independent task creation is unavailable.
7. A bilingual file map that identifies the canonical workflow, adapters, templates, index, and historic reports.
8. A short "What this is not" section: not a startup scoring engine, not a general knowledge base, not a mandatory long-form research process.
9. A privacy and maintenance note: the workspace is local Markdown; external search and model behavior depend on the chosen tool and configuration.

Use these two usage examples verbatim:

```text
I want a workflow that turns recurring Slack questions into reusable Codex skills.

Compare this idea with the cards I already have and tell me what I can reuse.
```

- [ ] **Step 2: Create the Chinese guide**

Create `README.zh-CN.md` with the same headings, information, limitations, file map, and two Chinese examples:

```text
我想把团队里反复出现的 Slack 问题整理成可复用的 Codex Skill。

把这个想法和已有灵感卡片对比一下，告诉我能复用什么。
```

Link back to `README.md` near the title. Do not promise automatic task creation in Claude Code or Cursor.

- [ ] **Step 3: Run the complete static check**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
git diff --check
```

Expected: exit code `0`, exact validator output `Workspace validation passed.`, and no whitespace errors.

- [ ] **Step 4: Review the public-facing wording**

Run:

```powershell
Get-Content .\README.md -Raw
Get-Content .\README.zh-CN.md -Raw
```

Expected: both files describe lightweight cards, related-idea checks, reuse analysis, and platform fallbacks; neither requires a long report or a fixed candidate count.

## Task 5: Run the Lightweight Acceptance Check and Prepare Safe Handoff

**Files:**

- Verify only: all files from Tasks 1–4

**Interfaces:**

- Consumes: the completed static contract.
- Produces: evidence that the workspace can guide a new card without altering historic reports.

- [ ] **Step 1: Verify the five acceptance paths against the canonical workflow**

Read the core workflow and confirm it has an explicit instruction for each scenario:

```powershell
Select-String -LiteralPath .\instructions\core-workflow.md -Pattern 'new idea','existing','duplicate','variant','complementary','dependency','1–3','Next step','paused'
Select-String -LiteralPath .\instructions\core-workflow.zh-CN.md -Pattern '新灵感','已有','重复','变体','互补','依赖','1–3','下一步','暂停'
```

Expected: each command returns evidence for new ideas, related ideas, limited references, next steps, and interruption handling.

- [ ] **Step 2: Verify historical reports remain byte-for-byte unchanged**

Run:

```powershell
$expectedHashes = @{
    '2026-08-13-policy-opportunity-radar.md' = 'C86D1CE2B8114EE553E62454614CB00D4BDEEEA256CD4738D2495392EAAD88F0'
    '2026-08-17-information-bubble-breaker.md' = '582121F9AD035A8C71BF8A5AD7F0472C5C650076D673FF0C502132C912797C05'
    '2026-08-17-landline-supplier-quotation-agent.md' = '87C3650E4B068E9B7053CF2E25C45E3D37B6CCE73373066E03DDD62E167024E4'
}
foreach ($name in $expectedHashes.Keys) {
    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path '.\ideas' $name)).Hash
    if ($actual -ne $expectedHashes[$name]) { throw "Historic report changed: $name" }
}
```

Expected: no output and exit code `0`.

- [ ] **Step 3: Run the final workspace checks**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
git diff --check
git status --short
```

Expected: validator and whitespace checks pass. Status shows only the designed workflow files and pre-existing user changes.

- [ ] **Step 4: Check repository-local Git identity before considering a commit**

Run:

```powershell
git config --local user.name
git config --local user.email
```

Expected: both values are nonempty before any commit is attempted. If either is empty, do not set a global identity, do not invent one, and leave all changes uncommitted for the user to review.

## Spec Coverage Review

- Cross-tool adapters: Task 2.
- Canonical rule and complete Chinese counterpart: Task 2.
- Lightweight cards, relation checks, and reuse fields: Task 3.
- One bilingual index with preserved history: Task 3.
- Complete bilingual public documentation: Task 4.
- No fixed-report or candidate-count contract: Tasks 1–4.
- Static and acceptance validation: Tasks 1 and 5.
- Historic report preservation and safe Git handoff: Task 5.
