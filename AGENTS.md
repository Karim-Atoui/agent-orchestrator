# AGENTS — agent-orchestrator repo

This repository ships **Cursor skills, templates, and docs** for the orchestrator workflow. It is not a deployed service.

## When editing the skill

- Frontmatter `name`: **`orchestrate`** (slash **`/orchestrate`**); folder: **`orchestrator`** (stable path).
- **`SKILL.md`** — workflow, phases, delegation, handoffs; keep under ~500 lines.
- **`reference.md`** — confidence math, escalation thresholds, permissions, verify/GitHub contract, and **Task/subagent routing** (tables); keep long threshold lists here, not in `SKILL.md`.
- **Slash** — single entry via skill `name` (no separate `.cursor/commands/` file).
- Templates: `.cursor/skills/orchestrator/templates/` — keep aligned with `SKILL.md` phases.
- Changing escalation numbers: update **`reference.md`** and **`pipeline.config.example.yaml`** together.

## Consuming repos

Application codebases should add their own `AGENTS.md` with: stack, how to run `./scripts/verify.sh`, branch naming, and anything agents must never do.