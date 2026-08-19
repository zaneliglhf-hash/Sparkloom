# AI Inspiration Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Codex project workflow that recognizes new AI inspirations from natural conversation, creates one independent task per inspiration, researches scenario-similar projects, and archives each result as a Markdown report with a central index.

**Architecture:** `AGENTS.md` is the behavioral control plane: it distinguishes the project-entry task from an inspiration-research task, creates a new Codex task only for a genuine new inspiration, and defines the research and archival contract. `templates/idea-report.md` is a flexible content schema, `ideas/INDEX.md` is the durable catalog, and `scripts/validate-workspace.ps1` provides deterministic structural checks without external dependencies. A marker named `[INSPIRATION_RESEARCH_TASK]` in the new-task seed prevents recursive task creation.

**Tech Stack:** Markdown, Codex project instructions, Codex task tools, GitHub plugin, web research, PowerShell validation, Git.

## Global Constraints

- The first version serves one user and does not add accounts, permissions, payments, a database, a backend, or a standalone UI.
- The user speaks naturally; no fixed prefix, form, or mode label is required.
- Obvious new inspirations create a new Codex task immediately; ambiguous messages trigger one concise confirmation question.
- Each inspiration has one independent Codex task and one Markdown report under `ideas/`.
- New research tasks contain `[INSPIRATION_RESEARCH_TASK]` and never create another task for the seeded inspiration.
- Research prioritizes matching user, problem, workflow, and outcome; shared technology alone is not high similarity.
- Standard research seeks roughly 10–20 credible candidates and deeply compares 3–5 highly similar candidates without padding weak results.
- Every completed report provides at least one evidence-backed differentiation direction or explains why evidence is insufficient.
- Personal-use ideas emphasize convenience, saved steps, maintenance, privacy, and reliability; commercial analysis appears only when relevant.
- Time-sensitive facts include a research date and link to primary or authoritative sources whenever available.
- Existing reports are never overwritten; filename collisions receive a numeric suffix.
- Git commits remain blocked until the user supplies or configures a repository-local Git author name and email.

---

## Planned File Map

- `AGENTS.md`: inspiration detection, task creation, research, report writing, index updates, and fallbacks.
- `README.md`: user-facing purpose, examples, lifecycle, and boundaries.
- `ideas/INDEX.md`: durable catalog with a fixed table schema and state vocabulary.
- `templates/idea-report.md`: flexible report template.
- `scripts/validate-workspace.ps1`: zero-dependency structural checks.
- `docs/superpowers/specs/2026-08-13-ai-inspiration-workflow-design.md`: approved design.
- `docs/superpowers/plans/2026-08-13-ai-inspiration-workflow.md`: this plan.

### Task 1: Install the Project Instruction Contract

**Files:**
- Create: `AGENTS.md`
- Create: `scripts/validate-workspace.ps1`

**Interfaces:**
- Consumes: the approved design document.
- Produces: a task seed marked `[INSPIRATION_RESEARCH_TASK]`, exact routing rules, and a validator whose success exit code is `0`.

- [ ] **Step 1: Write the failing validator**

Create `scripts/validate-workspace.ps1`:

```powershell
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

@(
    'AGENTS.md',
    'README.md',
    'ideas/INDEX.md',
    'templates/idea-report.md',
    'docs/superpowers/specs/2026-08-13-ai-inspiration-workflow-design.md'
) | ForEach-Object { Require-File $_ }

Require-Text 'AGENTS.md' '\[INSPIRATION_RESEARCH_TASK\]' 'the recursion-prevention marker'
Require-Text 'AGENTS.md' '明显是新灵感' 'the automatic creation rule'
Require-Text 'AGENTS.md' '是否.*独立.*任务' 'the ambiguity confirmation rule'
Require-Text 'AGENTS.md' '10.?20' 'the candidate target'
Require-Text 'AGENTS.md' '3.?5' 'the comparison target'
Require-Text 'AGENTS.md' '不得.*凑数|不.*凑数' 'the no-padding rule'
Require-Text 'README.md' '直接.*说出.*想法|自然.*说出.*想法' 'natural-language usage'
Require-Text 'README.md' '独立.*任务' 'one-task-per-inspiration guidance'
Require-Text 'README.md' 'ideas/INDEX.md' 'the catalog link'
Require-Text 'README.md' '10.?20' 'the productization review threshold'
Require-Text 'ideas/INDEX.md' '\| 灵感名称 \| 提出日期 \| 一句话描述 \| 状态 \| 报告 \|' 'the index schema'
Require-Text 'ideas/INDEX.md' '待研究.*研究中.*已完成.*暂停' 'the allowed states'
Require-Text 'templates/idea-report.md' '检索日期：' 'the research date'
Require-Text 'templates/idea-report.md' '适用时保留' 'optional-section guidance'
@('原始灵感','结论摘要','候选方案','重点项目对比','差异化方向','下一步验证','来源与检索说明') |
    ForEach-Object { Require-Text 'templates/idea-report.md' ("## " + $_) ("section " + $_) }

@('AGENTS.md','README.md','ideas/INDEX.md','templates/idea-report.md') | ForEach-Object {
    $path = Join-Path $projectRoot $_
    if ((Test-Path -LiteralPath $path -PathType Leaf) -and
        ((Get-Content -Raw -Encoding utf8 -LiteralPath $path) -match '(?im)\b(TBD|TODO)\b|待定|以后补充')) {
        $failures.Add("$_ contains unfinished placeholder text")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Output 'Workspace validation passed.'
exit 0
```

- [ ] **Step 2: Verify the validator fails before the workflow files exist**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit `1`, naming at least missing `AGENTS.md`, `README.md`, `ideas/INDEX.md`, and `templates/idea-report.md`.

- [ ] **Step 3: Create `AGENTS.md` with the full behavioral contract**

Create `AGENTS.md` with this complete content:

```markdown
# Inspiration 项目规则

## 任务角色

- 初始消息包含 `[INSPIRATION_RESEARCH_TASK]`：当前是灵感研究任务，不得为种子灵感再次创建任务。
- 不包含该标记：当前默认是项目入口任务。

## 入口任务

- 明显是新灵感：立即在当前 `Inspiration` 项目和工作区中创建独立任务，不要求固定前缀，也不再次确认。
- 可能只是补充、修改或普通讨论：只问一句“要把这个作为新灵感放到独立任务研究吗？”。
- 与已有灵感高度重复：询问是继续原任务，还是作为独立变体创建新任务。
- 普通讨论或既有灵感的延续：留在当前任务。

新任务使用简短中文标题，种子消息必须完整保留用户原话，并采用：

```text
[INSPIRATION_RESEARCH_TASK]
灵感标题：<简短中文名称>
原始灵感：<完整保留用户原话>
提出日期：<YYYY-MM-DD>

请在当前任务中研究这个灵感，不要为它再次创建任务。先判断信息是否足够；若不足，每次只问一个会改变检索方向的关键问题。完成后，将报告写入 ideas/<YYYY-MM-DD>-<stable-english-slug>.md，并更新 ideas/INDEX.md。
```

创建成功后，入口任务只返回导航，不展开研究。创建失败时在当前任务继续研究并说明情况，不能丢失原始灵感。

## 研究任务

先提取目标用户、使用场景、核心问题、期望结果、主要流程和可能形态。信息不足时，每次只问一个会改变检索方向的问题。

1. 搜索约 10–20 个可信候选，不得用低相关结果凑数。
2. 优先搜索 GitHub、官方产品与文档，再用技术或用户社区验证反馈。
3. 按目标用户、问题、工作流程和最终产出判断相似度；技术栈相同本身不算高度相似。
4. 重点比较 3–5 个高度相似项目；不足 3 个时说明检索范围和原因，不得凑数。
5. 至少提出一个有证据支持的差异化方向；证据不足时明确说明。
6. 易变化事实标注检索日期，并尽量引用第一方来源。

个人自用灵感重点分析方便性、减少的步骤、维护成本、隐私、稳定性和复用方案，不强制市场分析。只有明显面向他人或具有产品化意图时，才增加需求、竞争、获客、付费和合规分析。

## 报告与索引

- 从 `templates/idea-report.md` 开始，删除与当前灵感无关的可选章节。
- 报告保存为 `ideas/YYYY-MM-DD-stable-english-slug.md`。
- 同名文件使用 `-2`、`-3` 等后缀，不覆盖旧报告。
- 状态只使用：待研究、研究中、已完成、暂停。
- 创建报告时索引设为研究中；完成后设为已完成；中断且保留草稿时设为暂停。
- 索引每个灵感一行，使用相对报告链接。
- 链接失效、来源冲突、渠道不可用或事实无法验证时明确记录。

完成前确认原始灵感、检索范围、重点项目、差异化方向、适配语境的分析、来源和日期均已记录。默认只研究和归档；除非用户明确要求，不实现灵感、不发布内容、不联系第三方。
```

- [ ] **Step 4: Run the validator again**

Run the validator from Step 2.

Expected: it still exits `1` because README, index, and template are missing, but it reports none of the required `AGENTS.md` marker/routing/research errors.

- [ ] **Step 5: Stage this reviewable unit**

Run:

```powershell
git add -- AGENTS.md scripts/validate-workspace.ps1
git diff --cached --check
```

Expected: whitespace check exits `0`. Do not commit until repository-local Git author identity is configured.

### Task 2: Create the Durable Report Store

**Files:**
- Create: `ideas/INDEX.md`
- Create: `templates/idea-report.md`

**Interfaces:**
- Consumes: paths and states defined by `AGENTS.md`.
- Produces: table schema `| 灵感名称 | 提出日期 | 一句话描述 | 状态 | 报告 |` and a flexible report schema.

- [ ] **Step 1: Create `ideas/INDEX.md`**

Use exactly:

```markdown
# AI 灵感目录

这里汇总每个独立灵感任务生成的研究报告。状态只使用：待研究、研究中、已完成、暂停。

| 灵感名称 | 提出日期 | 一句话描述 | 状态 | 报告 |
|---|---|---|---|---|
```

- [ ] **Step 2: Create `templates/idea-report.md`**

Include these exact headings and fields:

```markdown
# <灵感名称>

- 提出日期：<YYYY-MM-DD>
- 检索日期：<YYYY-MM-DD>
- 状态：研究中

## 原始灵感

> <完整保留用户原话>

## 灵感解读

- 目标用户：
- 使用场景：
- 核心问题：
- 期望结果：
- 主要工作流程：
- 可能形态：

## 结论摘要

- 相似方案概况：
- 最值得关注的项目：
- 差异化空间：
- 推荐下一步：

## 候选方案

| 名称 | 类型 | 链接 | 场景相似度 | 活跃或产品状态 | 入选依据 |
|---|---|---|---|---|---|

说明实际检索渠道、搜索词与候选数量。候选不足时解释原因，不补入低相关结果。

## 重点项目对比

| 项目 | 相似场景 | 已覆盖需求 | 未解决问题 | 使用门槛 | 成本、隐私与稳定性 | 可借鉴之处 |
|---|---|---|---|---|---|---|

## 差异化方向

描述至少一个由项目资料或用户反馈支持的方向，并明确证据与推断的边界。证据不足时直接说明。

## 个人使用便利性（适用时保留）

- 可减少的步骤或重复操作：
- 对结果质量的影响：
- 可直接复用的工具：
- 开发与维护成本：
- 隐私、稳定性与模型依赖：

## 产品机会（适用时保留）

- 需求与目标用户：
- 竞争与替代方案：
- 获客和付费可能性：
- 商业或合规风险：

## 下一步验证

给出一个成本尽可能低、结果可观察的验证实验，包括操作、资源和成功信号。

## 来源与检索说明

- 检索日期：<YYYY-MM-DD>
- 检索渠道：
- 关键来源：
- 未验证或存在冲突的信息：
```

- [ ] **Step 3: Validate the report store**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit `1` only because `README.md` is missing; no index, state, template-section, date, or optional-section error remains.

- [ ] **Step 4: Stage the report store**

Run:

```powershell
git add -- ideas/INDEX.md templates/idea-report.md
git diff --cached --check
```

Expected: exit `0`.

### Task 3: Add User Guidance and Finish Static Verification

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: natural-language behavior and report paths from Tasks 1–2.
- Produces: user-facing operating guidance and a fully passing validator.

- [ ] **Step 1: Create `README.md`**

Create `README.md` with this complete content:

```markdown
# Inspiration

这是一个以 Codex 为入口的个人 AI 灵感研究工作台。它帮助我发现与新想法在用户、问题和使用场景上相似的现有项目，并把结论保存为 Markdown。

## 怎么使用

直接自然地说出一个关于 AI 使用方法、工作流、Skill、Agent、MCP、自动化或 AI 产品的想法，不需要固定前缀或表单。

- 明显的新灵感会立即进入一个独立任务。
- 如果一句话可能只是补充或普通讨论，Codex 会先询问是否放到独立任务。
- 每个独立任务只研究一个灵感，并生成一份 `ideas/` 下的报告。
- 所有报告都登记在 [AI 灵感目录](ideas/INDEX.md)。

## 每次研究会做什么

默认搜索约 10–20 个可信候选，优先覆盖 GitHub、官方产品和技术或用户社区；再选择 3–5 个场景高度相似的项目重点比较，并提出至少一个有证据支持的差异化方向。找不到足够相似项目时如实说明，不用低相关项目凑数。

个人自用想法重点考虑是否方便、省步骤、容易维护、保护隐私且稳定；只有想法明显面向其他用户时，才补充市场和商业价值分析。

## 文件

- `AGENTS.md`：项目运行规则。
- `ideas/INDEX.md`：灵感总目录。
- `ideas/*.md`：独立研究报告。
- `templates/idea-report.md`：可按实际灵感裁剪的报告模板。
- `scripts/validate-workspace.ps1`：结构和规则校验。

## 当前边界

第一阶段不做独立应用、账号、支付、数据库、后端或自动刷新。积累约 10–20 个真实灵感后，再根据实际使用习惯判断是否开发图形界面或自动跟踪功能。默认只研究和归档，不会在未经明确要求时实现某个灵感。
```

- [ ] **Step 2: Run all static checks**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit `0` and exact output `Workspace validation passed.`

- [ ] **Step 3: Verify the complete staged scope**

Run:

```powershell
git add -- README.md AGENTS.md ideas/INDEX.md templates/idea-report.md scripts/validate-workspace.ps1 docs/superpowers/specs/2026-08-13-ai-inspiration-workflow-design.md docs/superpowers/plans/2026-08-13-ai-inspiration-workflow.md
git diff --cached --check
git status --short
```

Expected: whitespace check exits `0`; status contains only the intended project files.

- [ ] **Step 4: Commit after Git identity becomes available**

Run:

```powershell
git config --local user.name
git config --local user.email
```

Expected: both print nonempty values. If either is empty, ask the user for repository-local name and email; never invent identity or change global configuration.

Once configured:

```powershell
git commit -m "feat: add AI inspiration research workflow"
```

Expected: one root commit containing design, plan, instructions, template, index, README, and validator.

### Task 4: Run One Real End-to-End Acceptance Test

**Files:**
- Create: `ideas/YYYY-MM-DD-<real-idea-slug>.md`
- Modify: `ideas/INDEX.md`
- Modify only if a defect is found: `AGENTS.md`, `templates/idea-report.md`, `scripts/validate-workspace.ps1`, or `README.md`

**Interfaces:**
- Consumes: one naturally worded real AI inspiration from the user.
- Produces: one independent Codex task, one report, and one linked index row.

- [ ] **Step 1: Obtain a real inspiration naturally**

Ask the user to state the next AI inspiration normally. Do not request a prefix, form, category, or mode.

- [ ] **Step 2: Verify task routing**

For an obvious new inspiration, create a Codex task immediately using the seed contract in `AGENTS.md`. For an ambiguous message, ask exactly one confirmation question.

Expected: the seed contains `[INSPIRATION_RESEARCH_TASK]`, the full original wording, date, Chinese title, and intended report path; the research task does not recursively create another task.

- [ ] **Step 3: Initialize archival state**

Copy the report template to an unused report filename, fill title/original wording/dates, and append:

```markdown
| <灵感名称> | <YYYY-MM-DD> | <一句话描述> | 研究中 | [查看报告](<YYYY-MM-DD>-<real-idea-slug>.md) |
```

- [ ] **Step 4: Perform standard research**

Search GitHub, official product sources, and relevant communities. Record real queries and date; list roughly 10–20 credible candidates when available; deeply compare 3–5 highly similar projects or explain why fewer exist. Put direct project or official links near supported claims.

Expected: no claim of exhaustive coverage, no weak-result padding, and at least one evidence-backed differentiation direction or an explicit evidence-insufficient finding.

- [ ] **Step 5: Tailor and finish the report**

For personal use, retain convenience, saved steps, maintenance, privacy, reliability, and reuse; remove irrelevant product analysis. For an external-user product, retain relevant product analysis. Remove every empty template field, then change report and index status to `已完成`.

- [ ] **Step 6: Validate the acceptance artifact**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
git diff --check
```

Expected: both exit `0`; the index link resolves; the report preserves original wording, research date, sources, candidates, focused comparison, differentiation, and next-step experiment.

- [ ] **Step 7: Commit after user review**

After the user reviews the first report:

```powershell
git add -- ideas/INDEX.md ideas/<YYYY-MM-DD>-<real-idea-slug>.md
git commit -m "docs: add first AI inspiration research report"
```

Expected: the commit contains only the index update and reviewed report unless a workflow defect was explicitly fixed.
