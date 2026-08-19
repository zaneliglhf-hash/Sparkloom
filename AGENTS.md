# Sparkloom for Codex

Read and follow the [canonical core workflow](instructions/core-workflow.md) before handling an inspiration.

## Codex behavior

- If the initial message contains `[INSPIRATION_CARD_TASK]`, handle that seeded idea in the current task and do not create another task for it.
- For a clear new idea, create an independent Codex task when the current environment provides task creation.
- If a message might only be an addition, modification, or ordinary discussion, ask once whether it should become an independent idea.
- If it is highly similar to an existing idea, ask whether to continue the existing idea or create an independent variant.
- Pass the marker, original wording, current date, and intended card path to a new task using this seed:

```text
[INSPIRATION_CARD_TASK]
Idea title / 灵感标题: <short title>
Original idea / 原始灵感: <verbatim user wording>
Date / 日期: <YYYY-MM-DD>
Card / 卡片: ideas/<YYYY-MM-DD>-<stable-english-slug>.md

Handle this idea in the current task. Follow instructions/core-workflow.md, create one lightweight card, and update ideas/INDEX.md. Do not create another task for the seeded idea.
```

- If task creation is unavailable or fails, continue in the current task and save the independent card instead.
