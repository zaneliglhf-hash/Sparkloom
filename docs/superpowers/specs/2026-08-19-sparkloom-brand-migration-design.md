# Sparkloom Brand Migration Design

**Date:** 2026-08-19

## Goal

Rename the public project brand from **Inspiration** to **Sparkloom** and present the tagline **Weave ideas into action.** consistently, without changing the workflow's meaning or renaming the local folder.

## Brand rules

- The product and repository name is `Sparkloom`.
- The public tagline is `Weave ideas into action.`
- Ordinary uses of “inspiration” or “灵感” remain unchanged when they describe an idea, card, collection, or workflow concept rather than the product name.
- The local workspace remains at `C:\Users\14436\Desktop\Inspiration`.
- The existing long GitHub repository description remains unchanged.

## Scope

Update current public and operational entry points:

- GitHub repository name: `IRW-inspiration-research-workflow` → `Sparkloom`;
- English and Chinese README titles and introductory product references;
- Codex, Claude Code, and Cursor adapter titles or descriptions where `Inspiration` is used as the project brand;
- current core-workflow and index titles where they identify the workspace itself;
- validator expectations that depend on those updated titles.

Preserve historical context:

- existing dated plan and design filenames remain unchanged;
- historical narrative is not rewritten merely to replace the former project name;
- idea-card paths and the `ideas/` directory remain unchanged.

## Implementation approach

Use targeted edits instead of a global text replacement. Each occurrence is classified as either a brand reference or a domain term. Only brand references change to `Sparkloom`.

The GitHub repository is renamed after the file changes are ready. The local `origin` URL is then updated to the canonical `Sparkloom` URL even though GitHub normally redirects the old URL.

## Validation

- Run `scripts/validate-workspace.ps1` after updating its relevant expectations.
- Search current operational files for stale brand references.
- Confirm generic inspiration terminology and historical documents were not unintentionally rewritten.
- Run GitGuardian against the changed files without displaying secret values.
- Verify the pushed branch, pull request, and renamed repository through GitHub.

## Failure handling

- If `Sparkloom` is unavailable under the GitHub account, stop before changing local references and report the naming conflict.
- If repository rename or remote update fails, retain the existing remote and do not force-push.
- If validation fails, fix the targeted references before publishing.
- The local folder is never moved or renamed as part of this migration.
