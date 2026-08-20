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
