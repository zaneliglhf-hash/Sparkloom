# Sparkloom Agent Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package Sparkloom as one repository-scoped Agent Skill named `sparkloom`, retain the Codex, Claude Code, and Cursor adapters, document project-scoped installation on GitHub, and publish the first Skill release as `v1.0.0`.

**Architecture:** `skills/sparkloom/SKILL.md` is the Agent Skills discovery entry point and contains a fail-closed Sparkloom workspace guard. It delegates shared idea handling to the existing root `instructions/core-workflow.md`, while the three existing adapters retain only platform-specific behavior and point into the Skill. Repository validation, Skill Creator validation, `gh skill` validation, GitGuardian scanning, a reviewed pull request, and release verification protect the publishing path.

**Tech Stack:** Markdown, YAML, PowerShell 7, Skill Creator Python utilities, `uv`, Git, GitHub CLI with `gh skill`, GitGuardian `ggshield`.

## Global Constraints

- The only Skill name and directory are `sparkloom` and `skills/sparkloom/`.
- The Skill is valid only in the Sparkloom repository; it must not scaffold or manage an ideas workspace in any unrelated repository.
- The exact required workspace markers are `README.md`, `instructions/core-workflow.md`, `ideas/INDEX.md`, `templates/inspiration-card.en.md`, and `templates/inspiration-card.zh-CN.md`.
- `instructions/core-workflow.md` remains the single normative workflow. Do not copy that workflow or either card template into the Skill.
- Resolve `instructions/core-workflow.md` from the active project root identified by the guard, never relative to the installed Skill directory; a project-scope install may live under an agent-specific directory such as `.agents/skills/sparkloom/`.
- Keep `AGENTS.md`, `CLAUDE.md`, and `.cursor/rules/inspiration-workflow.mdc`; each must route to the Skill and retain its platform-specific behavior.
- The Skill contains only `SKILL.md` and `agents/openai.yaml`; do not add `scripts/`, `references/`, `assets/`, examples, a Skill-local README, or generated scaffolding files.
- Automatic invocation remains enabled with `policy.allow_implicit_invocation: true`.
- The documented installation scope is exactly `--scope project`; do not install or document the Skill at user scope.
- The first published release is exactly `v1.0.0`. Stop if that tag or release already exists; do not overwrite, force-push, or replace it.
- Publication, pull-request merge, release creation, and other GitHub mutations require the authorization gates in Tasks 6 and 7.
- Do not publish ideas, contact third parties, or perform unrelated external mutations as part of the Skill workflow.

## File Map

- Create `skills/sparkloom/SKILL.md`: Skill discovery metadata, repository-only guard, canonical-workflow routing, and authorization boundaries.
- Create `skills/sparkloom/agents/openai.yaml`: Sparkloom UI metadata and implicit-invocation policy.
- Modify `scripts/validate-workspace.ps1`: executable structural contract for the new Skill, scope guard, adapters, README installation copy, and unfinished scaffold detection.
- Modify `AGENTS.md`: Codex adapter routes through the Skill while retaining Codex task behavior.
- Modify `CLAUDE.md`: Claude Code adapter routes through the Skill while retaining its isolation fallbacks.
- Modify `.cursor/rules/inspiration-workflow.mdc`: Cursor adapter routes through the Skill while retaining its current-chat behavior.
- Modify `README.md`: English project-scoped Skill installation and repository-only warning.
- Modify `README.zh-CN.md`: Chinese counterpart of the same installation and scope contract.

---

### Task 1: Add the Failing Repository Contract

**Files:**

- Modify: `scripts/validate-workspace.ps1`

**Interfaces:**

- Consumes: Existing `Require-File`, `Require-Text`, `Require-NotText`, and `Require-MarkdownLinkTarget` helpers.
- Produces: A validator contract that fails until the Skill, adapters, and bilingual installation documentation satisfy every approved design invariant.

- [ ] **Step 1: Extend the required-file list**

Add the two Skill files to the existing required-file array immediately after `.cursor/rules/inspiration-workflow.mdc`:

```powershell
    'skills/sparkloom/SKILL.md',
    'skills/sparkloom/agents/openai.yaml',
```

- [ ] **Step 2: Add the Skill package and repository-scope assertions**

Insert this block after the existing Sparkloom heading assertions:

```powershell
Require-Text 'skills/sparkloom/SKILL.md' '(?m)^name: sparkloom\r?$' 'the sparkloom skill name'
Require-Text 'skills/sparkloom/SKILL.md' '(?m)^license: MIT\r?$' 'the MIT skill license'
Require-Text 'skills/sparkloom/SKILL.md' '(?m)^## Repository-only scope\r?$' 'the repository-only scope guard'
Require-Text 'skills/sparkloom/SKILL.md' 'stop before creating or modifying files' 'the fail-closed scope behavior'
Require-Text 'skills/sparkloom/SKILL.md' 'read `instructions/core-workflow.md` from the active project root identified by the guard' 'project-root workflow resolution'
Require-NotText 'skills/sparkloom/SKILL.md' '../../instructions/core-workflow.md' 'the installed-Skill-relative workflow path'

@(
    'README.md',
    'instructions/core-workflow.md',
    'ideas/INDEX.md',
    'templates/inspiration-card.en.md',
    'templates/inspiration-card.zh-CN.md'
) | ForEach-Object {
    Require-Text 'skills/sparkloom/SKILL.md' ([regex]::Escape($_)) "the repository marker $_"
}

Require-Text 'skills/sparkloom/agents/openai.yaml' '(?m)^  display_name: "Sparkloom"\r?$' 'the Sparkloom display name'
Require-Text 'skills/sparkloom/agents/openai.yaml' '(?m)^  short_description: "Weave ideas into action in Sparkloom"\r?$' 'the Sparkloom skill summary'
Require-Text 'skills/sparkloom/agents/openai.yaml' '(?m)^  default_prompt: "Use \$sparkloom ' 'a default prompt that invokes the skill'
Require-Text 'skills/sparkloom/agents/openai.yaml' '(?m)^  allow_implicit_invocation: true\r?$' 'implicit skill invocation'
```

- [ ] **Step 3: Add the adapter and README assertions**

Insert this block after the existing adapter-to-core-workflow link assertions:

```powershell
Require-MarkdownLinkTarget 'AGENTS.md' 'skills/sparkloom/SKILL.md' 'the Sparkloom Skill'
Require-MarkdownLinkTarget 'CLAUDE.md' 'skills/sparkloom/SKILL.md' 'the Sparkloom Skill'
Require-MarkdownLinkTarget '.cursor/rules/inspiration-workflow.mdc' '../../skills/sparkloom/SKILL.md' 'the Sparkloom Skill'

$projectInstallCommand = 'gh skill install zaneliglhf-hash/Sparkloom sparkloom --agent codex --scope project'
Require-Text 'README.md' ([regex]::Escape($projectInstallCommand)) 'the project-scoped Codex Skill install command'
Require-Text 'README.zh-CN.md' ([regex]::Escape($projectInstallCommand)) 'the project-scoped Codex Skill install command'
Require-Text 'README.md' 'does not turn that repository into a Sparkloom workspace' 'the repository-only Skill warning'
Require-Text 'README.zh-CN.md' '不会把该仓库变成 Sparkloom 工作区' 'the repository-only Skill warning'
```

- [ ] **Step 4: Include the Skill in unfinished-scaffold detection**

Add these paths to the final array that checks for unfinished scaffold text:

```powershell
    'skills/sparkloom/SKILL.md',
    'skills/sparkloom/agents/openai.yaml',
```

- [ ] **Step 5: Run the validator and confirm the contract fails for the intended reasons**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit code `1`. The output includes both missing Skill files, missing Skill links in all three adapters, and missing project-scope installation/warning text in both README files. It must not report failures for the existing core workflows, templates, or index.

- [ ] **Step 6: Check and commit the failing contract**

Run:

```powershell
git diff --check
git add scripts/validate-workspace.ps1
git commit -m "Test the Sparkloom Agent Skill contract"
```

Expected: `git diff --check` is silent and the commit contains only `scripts/validate-workspace.ps1`.

---

### Task 2: Create the Repository-Scoped Skill Package

**Files:**

- Create: `skills/sparkloom/SKILL.md`
- Create: `skills/sparkloom/agents/openai.yaml`

**Interfaces:**

- Consumes: The exact marker paths in Task 1 and the canonical workflow at `instructions/core-workflow.md`, resolved from the active project root rather than from the installed Skill directory.
- Produces: A discoverable Skill named `sparkloom` whose UI metadata, scope guard, workflow route, and authorization boundaries are consumed by adapters, validators, and `gh skill publish`.

- [ ] **Step 1: Confirm the Skill directory does not already exist**

Run:

```powershell
if (Test-Path -LiteralPath .\skills\sparkloom) {
    throw 'skills/sparkloom already exists; inspect it instead of re-running the initializer.'
}
```

Expected: no output and exit code `0`. If it throws, stop and inspect the existing directory rather than overwriting it.

- [ ] **Step 2: Initialize only the required Skill files**

Run:

```powershell
$sparkloomPython = 'C:\Users\14436\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$sparkloomInitializer = 'C:\Users\14436\.codex\skills\.system\skill-creator\scripts\init_skill.py'

& $sparkloomPython $sparkloomInitializer sparkloom --path skills `
    --interface 'display_name=Sparkloom' `
    --interface 'short_description=Weave ideas into action in Sparkloom' `
    --interface 'default_prompt=Use $sparkloom to compare this AI-workflow idea with the Sparkloom workspace and create its next lightweight card.'
```

Expected: exit code `0`; the initializer creates `skills/sparkloom/SKILL.md` and `skills/sparkloom/agents/openai.yaml`, and creates no `scripts`, `references`, or `assets` directory.

- [ ] **Step 3: Replace the generated `SKILL.md` with the complete Skill**

Use `apply_patch` so `skills/sparkloom/SKILL.md` has exactly this content:

```markdown
---
name: sparkloom
description: Capture, compare, and advance AI-workflow ideas inside the Sparkloom repository. Use when working in a Sparkloom workspace to relate a new idea to existing cards, identify reusable work, create one lightweight idea card, and update the index; do not use it to scaffold or manage ideas in unrelated repositories.
license: MIT
---

# Sparkloom

Use Sparkloom only inside the Sparkloom repository.

## Repository-only scope

Before handling an idea, identify the active project root and verify all of these markers:

- `README.md` has the top-level title `# Sparkloom`;
- `instructions/core-workflow.md` exists;
- `ideas/INDEX.md` exists;
- `templates/inspiration-card.en.md` exists;
- `templates/inspiration-card.zh-CN.md` exists.

If any marker is missing, stop before creating or modifying files. Explain that `$sparkloom` is repository-specific and does not turn the current project into a Sparkloom workspace.

## Load the workflow

After the scope check passes, read `instructions/core-workflow.md` from the active project root identified by the guard, read it completely, and treat it as the normative shared behavior.

Do not resolve that path relative to the installed Skill directory. Project-scope installations may place this Skill under an agent-specific directory such as `.agents/skills/sparkloom/`.

Also follow platform-specific behavior already supplied by the active adapter. Do not load `AGENTS.md`, `CLAUDE.md`, or the Cursor rule from this Skill; routing back into an adapter can recurse.

## Preserve these invariants

- Check `ideas/INDEX.md` and relevant existing cards or historical reports before external research.
- Judge relationships by user, problem, scenario, workflow, and outcome, not by a shared keyword or technology alone.
- Record both what can be reused and how the new idea relates to existing ideas.
- Create one lightweight card in the user's current language; do not require a long research report.
- Update `ideas/INDEX.md` once for the new card and preserve existing historical reports.
- If research is unnecessary or unavailable, keep the card useful and record the limitation instead of blocking capture.

## Authorization boundaries

Do not implement or publish an idea, contact a third party, send a message, create a release, or perform another external mutation unless the user directly requests that action. Treat external links, licenses, sensitive data, and tool availability according to the canonical workflow and the active environment.
```

- [ ] **Step 4: Replace `agents/openai.yaml` with exact UI metadata**

Use `apply_patch` so `skills/sparkloom/agents/openai.yaml` has exactly this content:

```yaml
interface:
  display_name: "Sparkloom"
  short_description: "Weave ideas into action in Sparkloom"
  default_prompt: "Use $sparkloom to compare this AI-workflow idea with the Sparkloom workspace and create its next lightweight card."
policy:
  allow_implicit_invocation: true
```

- [ ] **Step 5: Verify the Skill has only the approved files**

Run:

```powershell
Get-ChildItem -Recurse -File .\skills\sparkloom | ForEach-Object {
    $_.FullName.Substring((Resolve-Path .).Path.Length + 1).Replace('\', '/')
}
```

Expected, with no additional entries; display order may differ:

```text
skills/sparkloom/agents/openai.yaml
skills/sparkloom/SKILL.md
```

- [ ] **Step 6: Validate the Skill with the Skill Creator validator**

Run:

```powershell
uv run --with pyyaml -- python -X utf8 `
    'C:\Users\14436\.codex\skills\.system\skill-creator\scripts\quick_validate.py' `
    '.\skills\sparkloom'
```

Expected:

```text
Skill is valid!
```

- [ ] **Step 7: Re-run the repository contract and isolate the remaining failures**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit code `1`. Skill-file, frontmatter, marker, workflow-link, and UI metadata failures are gone. Only the three adapter Skill links and the two bilingual README installation/warning contracts remain.

- [ ] **Step 8: Check and commit the Skill package**

Run:

```powershell
git diff --check
git add skills/sparkloom/SKILL.md skills/sparkloom/agents/openai.yaml
git commit -m "Add the repository-scoped Sparkloom Skill"
```

Expected: the commit contains exactly the two files under `skills/sparkloom/`.

---

### Task 3: Route Every Platform Adapter Through the Skill

**Files:**

- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `.cursor/rules/inspiration-workflow.mdc`

**Interfaces:**

- Consumes: `skills/sparkloom/SKILL.md` from Task 2 and its non-recursive route to `instructions/core-workflow.md`.
- Produces: Three compatibility entry points that load the Skill once and then apply only their existing platform-specific behavior.

- [ ] **Step 1: Update the Codex adapter introduction**

Replace the current sentence below `# Sparkloom for Codex` with:

```markdown
Read and follow the repository Skill at [skills/sparkloom/SKILL.md](skills/sparkloom/SKILL.md), then apply the Codex behavior below. The Skill loads the [canonical core workflow](instructions/core-workflow.md).
```

Keep the complete `## Codex behavior` section, including `[INSPIRATION_CARD_TASK]`, unchanged.

- [ ] **Step 2: Update the Claude Code adapter introduction**

Replace the current sentence below `# Sparkloom for Claude Code` with:

```markdown
Read and follow the repository Skill at [skills/sparkloom/SKILL.md](skills/sparkloom/SKILL.md), then apply the Claude Code behavior below. The Skill loads the [canonical core workflow](instructions/core-workflow.md).
```

Keep the complete `## Claude Code behavior` section unchanged.

- [ ] **Step 3: Update the Cursor adapter introduction**

Replace the current sentence below `# Sparkloom for Cursor` with:

```markdown
Read and follow the repository Skill at [skills/sparkloom/SKILL.md](../../skills/sparkloom/SKILL.md), then apply the Cursor behavior below. The Skill loads the [canonical core workflow](../../instructions/core-workflow.md).
```

Keep the YAML frontmatter and the complete `## Cursor behavior` section unchanged.

- [ ] **Step 4: Prove the adapters point inward without a recursion edge**

Run:

```powershell
$adapterPaths = @('AGENTS.md', 'CLAUDE.md', '.cursor/rules/inspiration-workflow.mdc')
Select-String -Path $adapterPaths `
    -Pattern 'skills/sparkloom/SKILL.md', 'instructions/core-workflow.md' `
    -SimpleMatch

$skillText = Get-Content -Raw -Encoding utf8 .\skills\sparkloom\SKILL.md
if ($skillText -match '\]\([^)]*(AGENTS\.md|CLAUDE\.md|inspiration-workflow\.mdc)[^)]*\)') {
    throw 'The Skill contains a recursive Markdown link back to an adapter.'
}
'No recursive adapter links found.'
```

Expected: `Select-String` shows all adapters pointing to the Skill and the canonical workflow, followed by `No recursive adapter links found.`

- [ ] **Step 5: Re-run the repository contract**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit code `1`; all adapter Skill-link failures are gone, leaving only English and Chinese README installation/warning failures.

- [ ] **Step 6: Check and commit the adapter routing**

Run:

```powershell
git diff --check
git add AGENTS.md CLAUDE.md .cursor/rules/inspiration-workflow.mdc
git commit -m "Route Sparkloom adapters through the Skill"
```

Expected: the commit contains only the three adapter files.

---

### Task 4: Document Project-Scoped Installation in Both READMEs

**Files:**

- Modify: `README.md`
- Modify: `README.zh-CN.md`

**Interfaces:**

- Consumes: The remote repository `zaneliglhf-hash/Sparkloom`, Skill name `sparkloom`, Codex agent identifier `codex`, and repository-only contract from Task 2.
- Produces: GitHub-visible English and Chinese instructions that use project scope and explicitly reject cross-repository workspace conversion.

- [ ] **Step 1: Add the English Agent Skill section**

Insert this section between the introductory paragraphs and `## What you get`:

````markdown
## Install the Agent Skill

The `sparkloom` Agent Skill is specific to this repository. From the Sparkloom repository, install it for Codex at project scope:

```powershell
gh skill install zaneliglhf-hash/Sparkloom sparkloom --agent codex --scope project
```

Installing this Skill into another repository does not turn that repository into a Sparkloom workspace. The Skill stops before writing files unless Sparkloom's required workflow, index, and templates are present.
````

- [ ] **Step 2: Add the Chinese Agent Skill section**

Insert this section between the introductory paragraphs and `## 每条灵感会得到什么`:

````markdown
## 安装 Agent Skill

`sparkloom` Agent Skill 只适用于本仓库。请在 Sparkloom 仓库内以项目范围为 Codex 安装：

```powershell
gh skill install zaneliglhf-hash/Sparkloom sparkloom --agent codex --scope project
```

把这个 Skill 安装到其他仓库，不会把该仓库变成 Sparkloom 工作区。如果缺少 Sparkloom 的工作流、目录或模板，Skill 会在写入文件前停止。
````

- [ ] **Step 3: Run the complete repository validator**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected:

```text
Workspace validation passed.
```

- [ ] **Step 4: Check bilingual parity and scope wording**

Run:

```powershell
Select-String -Path README.md,README.zh-CN.md `
    -Pattern 'gh skill install', 'scope project', 'repository', '仓库', 'Sparkloom workspace', 'Sparkloom 工作区' `
    -SimpleMatch

$userScopeHits = Select-String -Path README.md,README.zh-CN.md,skills/sparkloom/SKILL.md `
    -Pattern '--scope user' -SimpleMatch
if ($userScopeHits) {
    throw "User-scope installation was documented: $($userScopeHits | Out-String)"
}
'No user-scope installation found.'
```

Expected: `Select-String` shows installation and repository-only language in both README files, followed by `No user-scope installation found.`

- [ ] **Step 5: Check and commit the GitHub-facing documentation**

Run:

```powershell
git diff --check
git add README.md README.zh-CN.md
git commit -m "Document project-scoped Sparkloom Skill installation"
```

Expected: the commit contains only the two README files.

---

### Task 5: Run Local, Behavioral, Publishing, and Security Validation

**Files:**

- Test: `skills/sparkloom/SKILL.md`
- Test: `skills/sparkloom/agents/openai.yaml`
- Test: `scripts/validate-workspace.ps1`
- Test: `AGENTS.md`
- Test: `CLAUDE.md`
- Test: `.cursor/rules/inspiration-workflow.mdc`
- Test: `README.md`
- Test: `README.zh-CN.md`

**Interfaces:**

- Consumes: The complete local branch after Tasks 1–4.
- Produces: Evidence that the workspace contract, Agent Skills specification, repo-only guard, secret scan, and Git diff are clean before any push.

- [ ] **Step 1: Run both structural validators**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
uv run --with pyyaml -- python -X utf8 `
    'C:\Users\14436\.codex\skills\.system\skill-creator\scripts\quick_validate.py' `
    '.\skills\sparkloom'
```

Expected:

```text
Workspace validation passed.
Skill is valid!
```

- [ ] **Step 2: Validate the repository with the publishing CLI without publishing**

Run:

```powershell
gh skill publish . --dry-run
```

Expected: exit code `0`; `gh skill` discovers `skills/sparkloom/SKILL.md`, validates the `sparkloom` name/frontmatter, and does not create a tag or release.

- [ ] **Step 3: Install into disposable positive and negative project-scope repositories**

Run this as one PowerShell block so the validated unique temporary root is always cleaned. Do not add `--force`, do not change either install to user scope, and do not run either install from the source repository:

```powershell
$ErrorActionPreference = 'Stop'
$sparkloomSource = 'C:\Users\14436\Desktop\Inspiration'
$sparkloomSystemTemp = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
)
$sparkloomInstallRoot = [System.IO.Path]::GetFullPath(
    (Join-Path $sparkloomSystemTemp ('sparkloom-project-install-' + [guid]::NewGuid().ToString()))
)
$sparkloomRootParent = [System.IO.Directory]::GetParent($sparkloomInstallRoot).FullName.TrimEnd(
    [System.IO.Path]::DirectorySeparatorChar,
    [System.IO.Path]::AltDirectorySeparatorChar
)
if (-not $sparkloomRootParent.Equals($sparkloomSystemTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The fixture root is not a direct child of system Temp: $sparkloomInstallRoot"
}
if ([System.IO.Path]::GetFileName($sparkloomInstallRoot) -notmatch '^sparkloom-project-install-[0-9a-f-]{36}$') {
    throw "The fixture root does not have the expected unique name: $sparkloomInstallRoot"
}
if (Test-Path -LiteralPath $sparkloomInstallRoot) {
    throw "The unique fixture root already exists: $sparkloomInstallRoot"
}

$sparkloomPositive = Join-Path $sparkloomInstallRoot 'positive'
$sparkloomNegative = Join-Path $sparkloomInstallRoot 'negative'
$sparkloomMarkers = @(
    'README.md',
    'instructions/core-workflow.md',
    'ideas/INDEX.md',
    'templates/inspiration-card.en.md',
    'templates/inspiration-card.zh-CN.md'
)

New-Item -ItemType Directory -Path $sparkloomPositive, $sparkloomNegative | Out-Null
try {
    git -C $sparkloomPositive init --quiet
    if ($LASTEXITCODE -ne 0) { throw 'Could not initialize the positive Git repository.' }
    git -C $sparkloomNegative init --quiet
    if ($LASTEXITCODE -ne 0) { throw 'Could not initialize the negative Git repository.' }

    foreach ($marker in $sparkloomMarkers) {
        $sourceMarker = Join-Path $sparkloomSource $marker
        $targetMarker = Join-Path $sparkloomPositive $marker
        New-Item -ItemType Directory -Path (Split-Path -Parent $targetMarker) -Force | Out-Null
        Copy-Item -LiteralPath $sourceMarker -Destination $targetMarker
    }

    Push-Location $sparkloomPositive
    try {
        gh skill install C:\Users\14436\Desktop\Inspiration sparkloom --from-local --agent codex --scope project
        if ($LASTEXITCODE -ne 0) { throw 'The positive project-scope install failed.' }
        $positiveList = @(gh skill list --agent codex --scope project)
        if ($LASTEXITCODE -ne 0) { throw 'The positive project-scope list failed.' }
        $positiveList | Write-Output
    }
    finally {
        Pop-Location
    }

    $positiveSkillPath = Join-Path $sparkloomPositive '.agents/skills/sparkloom/SKILL.md'
    $positiveOpenAIPath = Join-Path $sparkloomPositive '.agents/skills/sparkloom/agents/openai.yaml'
    if (-not (Test-Path -LiteralPath $positiveSkillPath -PathType Leaf)) {
        throw "The positive install is missing $positiveSkillPath"
    }
    if (-not (Test-Path -LiteralPath $positiveOpenAIPath -PathType Leaf)) {
        throw "The positive install is missing $positiveOpenAIPath"
    }
    if (($positiveList | Out-String) -notmatch '(?m)^sparkloom\s') {
        throw 'gh skill list did not discover sparkloom in the positive repository.'
    }
    $positiveSkillText = Get-Content -Raw -Encoding utf8 $positiveSkillPath
    if ($positiveSkillText -notmatch 'read `instructions/core-workflow\.md` from the active project root identified by the guard') {
        throw 'The installed positive Skill lost active-project-root workflow resolution.'
    }
    if ($positiveSkillText -match '\.\./\.\./instructions/core-workflow\.md') {
        throw 'The installed positive Skill contains a Skill-directory-relative workflow path.'
    }
    $positiveMissingMarkers = $sparkloomMarkers | Where-Object {
        -not (Test-Path -LiteralPath (Join-Path $sparkloomPositive $_) -PathType Leaf)
    }
    if ($positiveMissingMarkers) {
        throw "The positive repository is missing markers: $($positiveMissingMarkers -join ', ')"
    }
    if ((Get-Content -Raw -Encoding utf8 (Join-Path $sparkloomPositive 'README.md')) -notmatch '(?m)^# Sparkloom\r?$') {
        throw 'The positive README does not identify Sparkloom.'
    }
    'Positive installed Skill discovered; marker guard accepted.'

    Push-Location $sparkloomNegative
    try {
        gh skill install C:\Users\14436\Desktop\Inspiration sparkloom --from-local --agent codex --scope project
        if ($LASTEXITCODE -ne 0) { throw 'The negative project-scope install failed.' }
        $negativeList = @(gh skill list --agent codex --scope project)
        if ($LASTEXITCODE -ne 0) { throw 'The negative project-scope list failed.' }
        $negativeList | Write-Output
    }
    finally {
        Pop-Location
    }

    $negativeSkillPath = Join-Path $sparkloomNegative '.agents/skills/sparkloom/SKILL.md'
    $negativeOpenAIPath = Join-Path $sparkloomNegative '.agents/skills/sparkloom/agents/openai.yaml'
    if (-not (Test-Path -LiteralPath $negativeSkillPath -PathType Leaf)) {
        throw "The negative install is missing $negativeSkillPath"
    }
    if (-not (Test-Path -LiteralPath $negativeOpenAIPath -PathType Leaf)) {
        throw "The negative install is missing $negativeOpenAIPath"
    }
    if (($negativeList | Out-String) -notmatch '(?m)^sparkloom\s') {
        throw 'gh skill list did not discover sparkloom in the negative repository.'
    }
    $negativeMissingMarkers = $sparkloomMarkers | Where-Object {
        -not (Test-Path -LiteralPath (Join-Path $sparkloomNegative $_) -PathType Leaf)
    }
    if ($negativeMissingMarkers.Count -ne $sparkloomMarkers.Count) {
        throw 'The marker-free repository unexpectedly satisfies part of the Sparkloom guard.'
    }
    $negativeSkillText = Get-Content -Raw -Encoding utf8 $negativeSkillPath
    if ($negativeSkillText -notmatch 'stop before creating or modifying files') {
        throw 'The installed negative Skill lost its fail-closed instruction.'
    }
    $unexpectedNegativeTopLevel = Get-ChildItem -LiteralPath $sparkloomNegative -Force | Where-Object {
        $_.Name -notin @('.agents', '.git')
    }
    if ($unexpectedNegativeTopLevel) {
        throw "Guard testing created unexpected files: $($unexpectedNegativeTopLevel.Name -join ', ')"
    }
    if ((Test-Path -LiteralPath (Join-Path $sparkloomNegative 'ideas')) -or
        (Test-Path -LiteralPath (Join-Path $sparkloomNegative 'templates'))) {
        throw 'Guard testing created idea or template files in the negative repository.'
    }
    'Negative installed Skill discovered; marker guard rejected before idea writes.'
}
finally {
    if (Test-Path -LiteralPath $sparkloomInstallRoot) {
        $cleanupTarget = (Resolve-Path -LiteralPath $sparkloomInstallRoot).Path
        $cleanupParent = [System.IO.Directory]::GetParent($cleanupTarget).FullName.TrimEnd(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar
        )
        if (-not $cleanupParent.Equals($sparkloomSystemTemp, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to clean a target outside system Temp: $cleanupTarget"
        }
        if ([System.IO.Path]::GetFileName($cleanupTarget) -notmatch '^sparkloom-project-install-[0-9a-f-]{36}$') {
            throw "Refusing to clean a non-fixture target: $cleanupTarget"
        }
        Remove-Item -LiteralPath $cleanupTarget -Recurse -Force
    }
}
if (Test-Path -LiteralPath $sparkloomInstallRoot) {
    throw "Fixture cleanup failed: $sparkloomInstallRoot"
}
'Disposable project-scope installation fixture removed.'
```

Expected: both `gh skill install` calls exit `0` and report an installed `sparkloom` Skill under `.agents/skills/sparkloom`; both exact `gh skill list --agent codex --scope project` calls contain `sparkloom` with project scope. The positive repository prints `Positive installed Skill discovered; marker guard accepted.` The marker-free negative repository prints `Negative installed Skill discovered; marker guard rejected before idea writes.` without creating `ideas`, `templates`, or any top-level path other than `.agents` and `.git`. Cleanup prints `Disposable project-scope installation fixture removed.` and the unique direct child no longer exists.

- [ ] **Step 4: Run an independent forward test when the chosen execution mode authorizes a worker**

Give a fresh evaluator only the Skill path, the real Sparkloom root, an empty temporary directory, and these two prompts:

```text
Use $sparkloom in the Sparkloom repository to explain which files you would read before handling a new AI-workflow idea. Do not write files.
```

```text
Use $sparkloom in this empty repository to capture an AI-workflow idea. Do not assume files that are absent.
```

Expected: in the real repository, the evaluator identifies the canonical workflow, index, relevant existing cards/reports, and language-appropriate template. In the empty repository, it refuses to create files and explains that the Skill is limited to Sparkloom. If inline execution was selected without worker authorization, perform the same read-only walkthrough in the current session and record that it was not independent.

- [ ] **Step 5: Run GitGuardian over the complete repository history**

Run:

```powershell
& 'C:\Users\14436\AppData\Local\Programs\ggshield\ggshield-1.53.0-x86_64-pc-windows-msvc\ggshield.exe' `
    secret scan repo . --no-check-for-updates
```

Expected: exit code `0` and no secret incident. Do not use `--show-secrets` or `--exit-zero`.

- [ ] **Step 6: Review the complete branch diff and working tree**

Run:

```powershell
git diff --check main...HEAD
git diff --stat main...HEAD
git status --short --branch
```

Expected: `git diff --check` is silent; the stat contains only the eight implementation files plus the approved design and plan documents; the working tree is clean on `agent/sparkloom-agent-skill`.

---

### Task 6: Push the Branch and Tell GitHub the Skill Is Repository-Only

**Files:**

- No local file changes.

**Interfaces:**

- Consumes: Clean validation evidence from Task 5 and the branch `agent/sparkloom-agent-skill`.
- Produces: A GitHub pull request whose title and body explicitly disclose project scope, compatibility adapters, validation, and the pending `v1.0.0` release.

- [ ] **Step 1: Refresh the base branch and confirm the branch is publishable**

Run:

```powershell
git fetch origin main
git merge-base --is-ancestor origin/main HEAD
git diff --check origin/main...HEAD
git status --short --branch
```

Expected: all commands exit `0`; the diff check is silent and the working tree is clean. If `origin/main` is not an ancestor, stop and reconcile without force-pushing.

- [ ] **Step 2: Push the implementation branch**

Run:

```powershell
git push -u origin agent/sparkloom-agent-skill
```

Expected: the remote branch is created or fast-forwarded; no forced update occurs.

- [ ] **Step 3: Create the pull request with the repository-only notice**

Run:

```powershell
$sparkloomPrBody = @'
## Summary

- publish Sparkloom as one Agent Skill named `sparkloom`
- route Codex, Claude Code, and Cursor adapters through the Skill
- document the project-scoped Codex install command in English and Chinese

## Scope notice

This Skill is intentionally repository-only. Installing it in another repository does not create a Sparkloom workspace, and the Skill stops before writing unless Sparkloom's workflow, index, and templates are present.

## Validation

- `pwsh -NoProfile -File .\scripts\validate-workspace.ps1`
- Skill Creator `quick_validate.py`
- `gh skill publish . --dry-run`
- positive and negative repository-scope fixtures
- GitGuardian repository scan

## Release

After review and merge, publish the first Agent Skill release as `v1.0.0`.
'@

gh pr create `
    --repo zaneliglhf-hash/Sparkloom `
    --base main `
    --head agent/sparkloom-agent-skill `
    --draft `
    --title 'Publish Sparkloom as a repository-scoped Agent Skill' `
    --body $sparkloomPrBody
```

Expected: GitHub prints one new pull-request URL. The visible PR body includes the repository-only scope notice.

- [ ] **Step 4: Wait for pull-request checks and report the gate**

Run:

```powershell
gh pr checks agent/sparkloom-agent-skill --repo zaneliglhf-hash/Sparkloom --watch --fail-fast
gh pr view agent/sparkloom-agent-skill --repo zaneliglhf-hash/Sparkloom --json number,url,state,mergeStateStatus,headRefOid
```

Expected: required checks pass, the PR state is `OPEN`, and the merge state is not blocked by a failing check. Report the PR URL and head SHA, then stop for explicit merge-and-release authorization.

---

### Task 7: Merge the Reviewed Pull Request

**Files:**

- No local file changes.

**Interfaces:**

- Consumes: Explicit user approval for the exact open PR, its reviewed head SHA, and passing checks.
- Produces: A squash merge on `main` whose commit is the only release target for Task 8.

- [ ] **Step 1: Re-check approval-sensitive PR state**

Run:

```powershell
$sparkloomPr = gh pr view agent/sparkloom-agent-skill `
    --repo zaneliglhf-hash/Sparkloom `
    --json number,url,state,mergeStateStatus,headRefOid | ConvertFrom-Json
$sparkloomPr | ConvertTo-Json -Depth 3
```

Expected: `state` is `OPEN`; `mergeStateStatus` permits merge; `headRefOid` matches the SHA shown to the user at the Task 6 gate. If the SHA changed, stop and re-run Task 5 plus PR checks before seeking approval again.

- [ ] **Step 2: Merge exactly the approved head**

Run only after explicit user authorization:

```powershell
gh pr merge $sparkloomPr.number `
    --repo zaneliglhf-hash/Sparkloom `
    --squash `
    --match-head-commit $sparkloomPr.headRefOid
```

Expected: GitHub reports a successful squash merge. Do not use `--admin`, do not force a merge, and do not delete the branch in this step.

- [ ] **Step 3: Synchronize and revalidate `main`**

Run:

```powershell
git switch main
git pull --ff-only origin main
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
uv run --with pyyaml -- python -X utf8 `
    'C:\Users\14436\.codex\skills\.system\skill-creator\scripts\quick_validate.py' `
    '.\skills\sparkloom'
gh skill publish . --dry-run
git status --short --branch
```

Expected: both validators and the publish dry run pass; local `main` is clean and matches `origin/main`.

---

### Task 8: Publish and Verify `v1.0.0`

**Files:**

- No local file changes.

**Interfaces:**

- Consumes: Validated merged `main`, no existing `v1.0.0` tag or release, and the user's release authorization from the Task 6 gate.
- Produces: GitHub Release `v1.0.0`, the `agent-skills` repository topic, and a remotely previewable `sparkloom@v1.0.0` Skill.

- [ ] **Step 1: Prove that the version is unused**

Run:

```powershell
$sparkloomReleaseProbe = gh api repos/zaneliglhf-hash/Sparkloom/releases/tags/v1.0.0 2>&1
$sparkloomReleaseExit = $LASTEXITCODE
if ($sparkloomReleaseExit -eq 0) {
    throw "v1.0.0 release already exists: $($sparkloomReleaseProbe | Out-String)"
}
if (($sparkloomReleaseProbe | Out-String) -notmatch 'HTTP 404') {
    throw "Could not confirm release absence: $($sparkloomReleaseProbe | Out-String)"
}

$sparkloomTagProbe = gh api repos/zaneliglhf-hash/Sparkloom/git/ref/tags/v1.0.0 2>&1
$sparkloomTagExit = $LASTEXITCODE
if ($sparkloomTagExit -eq 0) {
    throw "The v1.0.0 tag already exists: $($sparkloomTagProbe | Out-String)"
}
if (($sparkloomTagProbe | Out-String) -notmatch 'HTTP 404') {
    throw "Could not confirm tag absence: $($sparkloomTagProbe | Out-String)"
}
'v1.0.0 is available.'
```

Expected:

```text
v1.0.0 is available.
```

Any existing tag or release is a hard stop; do not delete or replace it.

- [ ] **Step 2: Publish non-interactively with the exact version**

Run:

```powershell
gh skill publish . --tag v1.0.0
```

Expected: exit code `0`; `gh skill` validates the Skill, adds the `agent-skills` topic when absent, pushes the tag without force, and creates the GitHub Release `v1.0.0`.

- [ ] **Step 3: Verify the release and repository topic**

Run:

```powershell
gh release view v1.0.0 `
    --repo zaneliglhf-hash/Sparkloom `
    --json tagName,name,isDraft,isPrerelease,targetCommitish,url

gh repo view zaneliglhf-hash/Sparkloom `
    --json nameWithOwner,url,repositoryTopics `
    --jq '{nameWithOwner: .nameWithOwner, url: .url, topics: [.repositoryTopics[].name]}'
```

Expected: the release tag is `v1.0.0`, `isDraft` and `isPrerelease` are both `false`, and repository topics include `agent-skills`.

- [ ] **Step 4: Preview the published Skill at the immutable version**

Run:

```powershell
gh skill preview zaneliglhf-hash/Sparkloom sparkloom@v1.0.0
```

Expected: the preview discovers `skills/sparkloom/SKILL.md`, renders the `sparkloom` frontmatter and repository-only instructions, and shows the Skill file tree without an install error.

- [ ] **Step 5: Perform the final clean-state handoff**

Run:

```powershell
git rev-parse HEAD
git rev-parse origin/main
git status --short --branch
```

Expected: the two SHAs match and the working tree is clean. Report the PR URL, release URL, preview result, exact `main` SHA, and that the Skill remains restricted to the Sparkloom repository.
