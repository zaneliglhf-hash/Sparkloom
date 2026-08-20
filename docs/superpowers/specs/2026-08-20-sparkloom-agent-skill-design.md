# Sparkloom Agent Skill Design

**Date:** 2026-08-20

## Goal

Package Sparkloom as one discoverable Agent Skill named `sparkloom`, keep it restricted to the Sparkloom repository, preserve the existing Codex, Claude Code, and Cursor entry points, and publish the first Skill release as `v1.0.0`.

## Chosen approach

Add a repository-owned Skill at `skills/sparkloom/SKILL.md`. The Skill is the common entry point for Agent Skills discovery, while the existing root workflow, templates, index, and idea cards remain in their current locations.

The Skill does not duplicate the core workflow or templates. It verifies that the active project is Sparkloom, then reads the existing canonical workflow from the active project root before handling an idea. It must not resolve that workflow path relative to the installed Skill directory because a project-scope install may place the Skill in an agent-specific directory such as `.agents/skills/sparkloom/`. Platform adapters load the Skill and supply their platform-specific behavior separately, so the Skill never routes back into an adapter. This preserves one maintained copy of each rule, avoids recursive loading, and keeps current paths stable.

## Skill structure

```text
skills/
`-- sparkloom/
    |-- SKILL.md
    `-- agents/
        `-- openai.yaml
```

`SKILL.md` contains:

- YAML frontmatter with `name: sparkloom`, a discriminating description, and `license: MIT`;
- the repository-only scope guard;
- project-root resolution of `instructions/core-workflow.md`, never Skill-directory-relative resolution, while respecting the already-loaded platform adapter;
- the non-obvious invariants for relation checks, reusable-content capture, lightweight cards, and index updates;
- authorization boundaries that prevent publishing, contacting third parties, or other external mutations without a direct user request.

`agents/openai.yaml` provides UI metadata consistent with the Sparkloom name and tagline. Automatic discovery remains enabled.

## Repository-only scope

The Skill is valid only when the active project root contains all of these markers:

- `README.md` identifying `Sparkloom`;
- `instructions/core-workflow.md`;
- `ideas/INDEX.md`;
- `templates/inspiration-card.en.md`;
- `templates/inspiration-card.zh-CN.md`.

If the markers are missing, the Skill stops before creating files and explains that it is designed only for the Sparkloom repository. It does not scaffold an `ideas/` workspace in another project.

## Compatibility entry points

The existing adapters remain available:

- `AGENTS.md` for Codex;
- `CLAUDE.md` for Claude Code;
- `.cursor/rules/inspiration-workflow.mdc` for Cursor.

Each adapter first points to `skills/sparkloom/SKILL.md`. Platform-specific behavior remains in the adapter, while shared idea-handling rules remain in the canonical root workflow.

## Usage flow

1. Agent Skills discovery selects `sparkloom` for requests about capturing, comparing, or advancing an AI-workflow idea in this repository.
2. The Skill checks the repository markers.
3. The Skill reads `instructions/core-workflow.md` from the active project root identified by the guard and applies any platform-specific behavior already supplied by the active adapter.
4. The existing relation check, optional research, reuse capture, card creation, and index update workflow runs unchanged.
5. Existing authorization boundaries continue to apply to searches, publication, communication, and other external actions.

## GitHub documentation

The English and Chinese README files explain that the Skill is repository-specific and must be installed with project scope. The documented Codex command is:

```powershell
gh skill install zaneliglhf-hash/Sparkloom sparkloom --agent codex --scope project
```

The documentation also states that installing it into another repository does not make that repository a Sparkloom workspace.

## Validation

- Extend `scripts/validate-workspace.ps1` to require the Skill files, validate the project-scope guard text, require project-root workflow resolution, forbid the installed-Skill-relative `../../instructions/core-workflow.md` path, and confirm that all three adapters route to `skills/sparkloom/SKILL.md`.
- Run the Skill Creator `quick_validate.py` validator against `skills/sparkloom`.
- Run `gh skill publish --dry-run` against the repository.
- Run a repository-local behavior check that confirms the marker guard accepts Sparkloom and rejects a temporary non-Sparkloom directory without creating files.
- In a disposable direct child of the resolved system temporary directory, initialize positive and negative Git repositories and install the local Skill into each with `gh skill install C:\Users\14436\Desktop\Inspiration sparkloom --from-local --agent codex --scope project`. Verify the real `.agents/skills/sparkloom/` project-scope layout and `gh skill list` discovery in both repositories, then prove that the installed Skill resolves the canonical workflow from the active project root, accepts the copied Sparkloom markers in the positive repository, and rejects idea writes without creating workspace files in the marker-free negative repository. Validate the cleanup target before recursively removing only that unique temporary root.
- Scan every changed file with GitGuardian without displaying secret values.
- Verify the branch diff, pull request checks, and final `main` state.

## Publication

After the implementation pull request is explicitly approved and merged, run:

```powershell
gh skill publish --tag v1.0.0
```

The publication must create the `v1.0.0` GitHub Release and add the `agent-skills` repository topic. After publication, verify remote Skill preview and repository metadata. If the tag or release already exists, stop instead of overwriting it.

## Failure handling

- If Skill validation fails, do not publish; correct the package and rerun validation.
- If the repository-scope guard cannot reliably distinguish Sparkloom, stop before release.
- If `v1.0.0` already exists, stop and request a new version decision.
- If GitHub authentication, push, release creation, or preview verification fails, preserve the committed branch and report the exact remaining step.
- Never force-push, replace an existing release, or install the Skill at user scope as part of this work.
