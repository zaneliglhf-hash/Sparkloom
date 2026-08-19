# Inspiration Core Workflow

## Purpose

Capture AI-workflow ideas, check existing related work, record reusable parts, and choose a small next step. Store each new idea as one lightweight Markdown card.

## Workflow

1. Classify the input as a new idea, an addition, a variant, or ordinary discussion.
2. Before external searching, inspect `ideas/INDEX.md` and relevant existing cards or historical reports.
3. Record the relation as duplicate, variant, complementary, dependency, or no clear relation.
4. Ask one clarifying question only when the answer changes the search direction.
5. Search only as much as needed for 1–3 relevant GitHub projects, products, or sources.
6. Record reusable skills, agents, MCP servers, prompts, scripts, data sources, or design patterns.
7. Create or update one card and its index row.

Judge similarity by the target user, problem, usage scenario, workflow, and outcome. A shared keyword or technology stack is not enough by itself.

## Card requirements

Choose the card template matching the user's language. Every new card keeps Related ideas, What to reuse, and Next step. Do not create a duplicated second-language card for the same idea.

Use `ideas/YYYY-MM-DD-<stable-english-slug>.md`. If that path already exists, append `-2`, `-3`, and so on instead of overwriting it. Keep the original user wording in the card's one-line idea or opening context.

## Cross-platform behavior

Read the platform adapter before acting. Never claim that a platform can create independent chats or tasks when it cannot. Use an independent task when the platform supports it; otherwise use a separate card file to isolate the idea.

## Fallbacks

If existing cards cannot be read, note that the relation check was unavailable and continue. If external search is unavailable, record that limitation and do not present unverified model memory as a checked source. Preserve incomplete cards with a paused status. If task creation fails, continue in the current conversation so the idea is not lost.
