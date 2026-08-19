# Sparkloom Brand Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename the public project brand and GitHub repository to Sparkloom while preserving generic inspiration terminology, historical records, and the local `Inspiration` folder.

**Architecture:** Apply targeted text edits only to current public and operational entry points. Encode the new branding contract in the existing PowerShell validator before changing content, publish the file changes through a pull request, then rename the GitHub repository and update the local remote after the PR is merged.

**Tech Stack:** Markdown, PowerShell, Git, GitHub CLI, GitGuardian `ggshield`

## Global Constraints

- Product and repository name: `Sparkloom`.
- Public tagline: `Weave ideas into action.`
- Preserve ordinary uses of “inspiration” and “灵感” when they describe the domain rather than the product.
- Keep the local workspace at `C:\Users\14436\Desktop\Inspiration`.
- Keep the existing long GitHub repository description unchanged.
- Do not rename dated historical plans, historical specs, `ideas/`, card templates, or workflow paths.
- Do not force-push or overwrite a conflicting GitHub repository.

---

### Task 1: Encode the Sparkloom branding contract

**Files:**
- Modify: `scripts/validate-workspace.ps1:52-67`
- Test: `scripts/validate-workspace.ps1`

**Interfaces:**
- Consumes: existing `Require-Text` and `Require-NotText` validation helpers.
- Produces: executable assertions for the current project name, tagline, adapter headings, workflow headings, and index heading.

- [ ] **Step 1: Add the new branding assertions before changing content**

Insert after the required-file loop and before the workflow-section assertions:

```powershell
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
```

- [ ] **Step 2: Run the validator and verify the contract fails against the old brand**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit code `1`; output includes missing Sparkloom title, tagline, adapter heading, workflow heading, and index heading failures.

- [ ] **Step 3: Commit the failing contract**

```powershell
git add -- scripts/validate-workspace.ps1
git commit -m "Validate Sparkloom branding"
```

Expected: one commit containing only the validator change.

---

### Task 2: Update public README branding

**Files:**
- Modify: `README.md:1-7`
- Modify: `README.zh-CN.md:1-7`
- Test: `scripts/validate-workspace.ps1`

**Interfaces:**
- Consumes: the README branding assertions created in Task 1.
- Produces: bilingual public entry points with the same product name and tagline.

- [ ] **Step 1: Update the English README introduction**

Replace the opening with:

```markdown
# Sparkloom

*Weave ideas into action.*

[简体中文](README.zh-CN.md)

Sparkloom is a lightweight, cross-tool prior-art workspace for AI workflow ideas. Describe an idea naturally, compare it with what you already collected, record the most reusable parts of existing work, and choose one small next step.
```

Keep the remaining README content and generic uses such as “the inspiration index” unchanged.

- [ ] **Step 2: Update the Chinese README introduction**

Replace the opening with:

```markdown
# Sparkloom

*Weave ideas into action.*

[English](README.md)

Sparkloom 是一个跨工具的轻量 AI 工作流灵感工作台。你只需自然描述一个想法，它会先和已有灵感对比，再记录现有方案中最值得复用的部分，并给出一个最小下一步。
```

Keep the remaining Chinese README content and generic “灵感” terminology unchanged.

- [ ] **Step 3: Run the validator and inspect the remaining expected failures**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: README title and tagline failures disappear; adapter, workflow, and index branding failures remain.

- [ ] **Step 4: Commit the README branding**

```powershell
git add -- README.md README.zh-CN.md
git commit -m "Brand the Sparkloom readmes"
```

Expected: one commit containing only the two README files.

---

### Task 3: Update current operational branding

**Files:**
- Modify: `AGENTS.md:1`
- Modify: `CLAUDE.md:1`
- Modify: `.cursor/rules/inspiration-workflow.mdc:2,6`
- Modify: `instructions/core-workflow.md:1`
- Modify: `instructions/core-workflow.zh-CN.md:1`
- Modify: `ideas/INDEX.md:1`
- Test: `scripts/validate-workspace.ps1`

**Interfaces:**
- Consumes: operational branding assertions from Task 1.
- Produces: consistent Sparkloom naming across Codex, Claude Code, Cursor, the core workflow, and the index.

- [ ] **Step 1: Replace only the adapter brand headings**

Use these exact headings:

```markdown
# Sparkloom for Codex
# Sparkloom for Claude Code
# Sparkloom for Cursor
```

In `.cursor/rules/inspiration-workflow.mdc`, also change the frontmatter description to:

```yaml
description: Sparkloom workflow for lightweight cross-tool AI inspiration cards
```

Do not change `[INSPIRATION_CARD_TASK]`, file paths, or ordinary phrases such as “handling an inspiration.”

- [ ] **Step 2: Replace the workflow and index brand headings**

Use these exact headings:

```markdown
# Sparkloom Core Workflow
# Sparkloom 核心工作流
# Sparkloom Index / AI 灵感目录
```

- [ ] **Step 3: Run the complete workspace validator**

Run:

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

Expected: exit code `0` and `Workspace validation passed.`

- [ ] **Step 4: Check that operational brand references are consistent**

Run:

```powershell
$files = @('README.md','README.zh-CN.md','AGENTS.md','CLAUDE.md','.cursor/rules/inspiration-workflow.mdc','instructions/core-workflow.md','instructions/core-workflow.zh-CN.md','ideas/INDEX.md')
Select-String -LiteralPath $files -Pattern '^# Inspiration(?:$| for| Core)|^# Inspiration 核心工作流|^# Inspiration Index' -CaseSensitive
```

Expected: no output. Historical files are intentionally not included.

- [ ] **Step 5: Commit the operational branding**

```powershell
git add -- AGENTS.md CLAUDE.md .cursor/rules/inspiration-workflow.mdc instructions/core-workflow.md instructions/core-workflow.zh-CN.md ideas/INDEX.md
git commit -m "Apply Sparkloom operational branding"
```

Expected: one commit containing only the six operational files.

---

### Task 4: Validate security and publish the file changes

**Files:**
- Verify: all files changed since `main`
- Preserve: `docs/superpowers/plans/` and `docs/superpowers/specs/` historical files except the new migration documents

**Interfaces:**
- Consumes: the completed branding commits.
- Produces: a reviewed GitHub pull request targeting `main`.

- [ ] **Step 1: Review the complete branch diff**

Run:

```powershell
git status -sb
git diff --check main...HEAD
git diff --stat main...HEAD
```

Expected: a clean working tree; no whitespace errors; changes limited to the migration design, implementation plan, validator, README files, and operational entry points.

- [ ] **Step 2: Scan every changed file with GitGuardian**

Run:

```powershell
$changed = @(git diff --name-only main...HEAD | ForEach-Object { Join-Path (Get-Location) $_ })
ggshield secret scan path --yes --all-secrets @changed
```

Expected: exit code `0` and `No secrets have been found`. Do not add `--show-secrets`.

- [ ] **Step 3: Push the migration branch**

```powershell
git push -u origin agent/sparkloom-brand-migration
```

Expected: the remote branch is created without force-pushing.

- [ ] **Step 4: Open a draft pull request**

Create a draft PR from `agent/sparkloom-brand-migration` to `main` titled `Rename project brand to Sparkloom`. The body must summarize the targeted brand replacement, preservation of generic inspiration terminology and historical records, workspace validation, and GitGuardian scan.

Expected: one draft PR with the complete branch diff.

- [ ] **Step 5: Confirm checks, mark ready, and merge after user approval**

Run:

```powershell
$prNumber = gh pr view --repo zaneliglhf-hash/IRW-inspiration-research-workflow --json number --jq '.number'
gh pr checks $prNumber --repo zaneliglhf-hash/IRW-inspiration-research-workflow
```

Expected: all configured checks, including GitGuardian Security Checks, pass. After explicit user approval, mark the PR ready and squash-merge it.

---

### Task 5: Rename the GitHub repository and synchronize the local remote

**Files:**
- Modify: local Git configuration for remote `origin`
- Verify: local folder remains `C:\Users\14436\Desktop\Inspiration`

**Interfaces:**
- Consumes: the merged Sparkloom branding PR on `main`.
- Produces: canonical repository URL `https://github.com/zaneliglhf-hash/Sparkloom` and a synchronized local checkout.

- [ ] **Step 1: Verify the target repository name is not already in use**

Run:

```powershell
gh repo view zaneliglhf-hash/Sparkloom --json nameWithOwner
```

Expected: GitHub reports that `zaneliglhf-hash/Sparkloom` does not exist. If it exists, stop and report the conflict without renaming anything.

- [ ] **Step 2: Rename the repository**

Run:

```powershell
gh repo rename Sparkloom --repo zaneliglhf-hash/IRW-inspiration-research-workflow --yes
```

Expected: the repository becomes `zaneliglhf-hash/Sparkloom`; its long description and topics remain unchanged.

- [ ] **Step 3: Set the canonical local remote URL**

Run:

```powershell
git remote set-url origin https://github.com/zaneliglhf-hash/Sparkloom.git
git remote -v
```

Expected: fetch and push URLs both use `https://github.com/zaneliglhf-hash/Sparkloom.git`.

- [ ] **Step 4: Synchronize and verify the final state**

Run:

```powershell
git switch main
git pull --ff-only origin main
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
gh repo view zaneliglhf-hash/Sparkloom --json nameWithOwner,url,description,repositoryTopics,licenseInfo
git status -sb
```

Expected: local `main` matches `origin/main`; validation passes; GitHub reports `zaneliglhf-hash/Sparkloom`, the existing long description, existing topics, and MIT license; the working tree is clean; the local directory path is unchanged.
