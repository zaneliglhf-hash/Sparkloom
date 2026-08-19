# Inspiration

[简体中文](README.zh-CN.md)

Inspiration is a lightweight, cross-tool prior-art workspace for AI workflow ideas. Describe an idea naturally, compare it with what you already collected, record the most reusable parts of existing work, and choose one small next step.

It works as a local Markdown project for Codex, Claude Code, and Cursor. There is no application server, account, database, or required command syntax.

## What you get

Each new idea becomes one short card that captures:

- the idea in one sentence;
- its relationship to existing ideas;
- 1–3 useful external references when research is needed;
- skills, agents, MCP servers, prompts, scripts, data, or patterns worth reusing;
- the smallest observable next step.

Existing long-form reports remain available as historical material, but new ideas do not require a long research report.

## Quick start

Open this folder in a supported AI coding tool and speak naturally. For example:

```text
I want a workflow that turns recurring Slack questions into reusable Codex skills.
```

Or ask the tool to compare a new thought with the existing collection:

```text
Compare this idea with the cards I already have and tell me what I can reuse.
```

The workflow checks [the inspiration index](ideas/INDEX.md) first, reads relevant cards or historical reports, optionally finds a few close external references, and saves one language-appropriate card under `ideas/`.

## Supported tools

| Tool | Idea isolation behavior |
|---|---|
| Codex | Creates an independent task when the active environment supports task creation; otherwise saves the idea in a separate card from the current task. |
| Claude Code | Uses an available dedicated task or conversation; otherwise isolates the idea with a separate card file. |
| Cursor | Works in the current chat by default and isolates each idea with a separate card file. |

The adapters never assume a platform capability that is not present in the active environment. If task or chat creation fails, the current conversation continues so the idea is not lost.

## How the workflow decides similarity

Similarity is judged by target user, problem, usage scenario, workflow, and outcome. A shared keyword, model, framework, or technology stack is not enough by itself.

Before external research, the agent checks the current index and related files. It records the relationship as duplicate, variant, complementary, dependency, or no clear relation.

## Files

- `instructions/core-workflow.md`: normative workflow used by every platform.
- `instructions/core-workflow.zh-CN.md`: complete Chinese counterpart.
- `AGENTS.md`: Codex adapter.
- `CLAUDE.md`: Claude Code adapter.
- `.cursor/rules/inspiration-workflow.mdc`: Cursor adapter.
- `templates/inspiration-card.en.md`: English card template.
- `templates/inspiration-card.zh-CN.md`: Chinese card template.
- `ideas/INDEX.md`: single bilingual catalog for cards and historical reports.
- `scripts/validate-workspace.ps1`: zero-dependency structural validation.

## What this is not

- It is not a startup scoring engine or an automatic go-to-market report.
- It is not a general-purpose notes or knowledge-base application.
- It is not a mandatory long-form research process.
- It does not implement, publish, or contact third parties unless the user explicitly asks.

## Privacy and maintenance

The durable workspace is plain local Markdown and can be version-controlled or moved without a proprietary database. External search, model requests, privacy boundaries, and tool availability depend on the AI product and configuration you choose. Review external links, licenses, and sensitive data before reusing a project.

## Validate the workspace

```powershell
pwsh -NoProfile -File .\scripts\validate-workspace.ps1
```

A valid workspace prints `Workspace validation passed.`
