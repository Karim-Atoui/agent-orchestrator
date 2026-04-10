# AGENTS — agent-orchestrator repo

This repository ships **Cursor skills, templates, and docs** for the dev pipeline. It is not a deployed service.

## When editing the skill

- Keep `SKILL.md` under ~500 lines; put thresholds and tables in `reference.md`.
- Templates live in `.cursor/skills/dev-pipeline-orchestrator/templates/`; keep `PLAN.template.md` and `PR.template.md` in sync with the pipeline steps in `SKILL.md`.
- If you change escalation numbers, update both `reference.md` and `pipeline.config.example.yaml`.

## Consuming repos

Application codebases should add their own `AGENTS.md` with: stack, how to run `./scripts/verify.sh`, branch naming, and anything agents must never do.
