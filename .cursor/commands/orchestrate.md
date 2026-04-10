# Orchestrate

You are running the **dev-pipeline-orchestrator** workflow for this workspace. Follow it end-to-end unless the user stops you.

## Skill source

Use the skill at `~/.cursor/skills/dev-pipeline-orchestrator/` (project copy: `.cursor/skills/dev-pipeline-orchestrator/`). Read `SKILL.md` and `reference.md` for thresholds, confidence rules, and escalation.

## Task (user fills below — keep or replace)

**Goal:**

**GitHub issue (optional):**

**Constraints (optional):**

## What to do (strict order)

1. **Intake** — Restate goal, acceptance criteria, out of scope; propose branch `agent/<slug>-<YYYYMMDD>`.
2. **Plan** — Fill `templates/PLAN.template.md` from the skill (or equivalent structure in chat).
3. **GATE** — **Stop.** Wait for explicit human approval of the plan. No implementation until approved.
4. **Implement** — Approved scope only; match project style.
5. **Verify** — Run the repo’s single verify entrypoint: `pipeline.config.yaml` → `verify.command`, else `./scripts/verify.sh`, else what `AGENTS.md` / README documents.
6. **Docs** — Update only if behavior or public API changed; otherwise state “no doc changes.”
7. **GATE** — **Stop.** Present PR summary, test evidence, doc delta. Wait for approval before `git push` / `gh pr create`.
8. **PR** — Push branch; `gh pr create` using `templates/PR.template.md` for the body (draft if user prefers).

## Confidence

After each major step, output **Confidence: 0.0–1.0** with one-line rationale and **Escalation: none | required** per `reference.md`.

## Escalation stops

If the same verify failure repeats 3 times, total verify failures ≥ 5, or confidence ≤ 0.34: **stop**, summarize, offer options — do not loop blindly.

## GitHub

Target **github.com**; use `gh` when available. Base branch from `pipeline.config.yaml` or repo default (`main` if unknown).
