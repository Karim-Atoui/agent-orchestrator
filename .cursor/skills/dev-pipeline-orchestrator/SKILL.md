---
name: dev-pipeline-orchestrator
description: >-
  Runs a sequential software delivery pipeline from task intake through plan approval,
  implementation, verification, documentation updates, and GitHub PR—with confidence
  tracking and human escalation. Use when the user wants an orchestrated dev workflow,
  agent-as-team pipeline, plan/PR gates, or references dev-pipeline-orchestrator.
---

# Dev pipeline orchestrator

## Purpose

Execute a **single-threaded** pipeline: intake → plan → **human approves plan** → implement → verify → docs (if needed) → **human approves PR** → open PR on GitHub. Maintain a **confidence score** (0.0–1.0) and **stop for human decision** when escalation rules fire.

Do **not** spawn parallel coding agents unless the user explicitly opts in; default is sequential.

## Before starting

1. Confirm **workspace root** is the **target application repository** (not the orchestrator kit). If unclear, ask once.
2. Read project context: `AGENTS.md`, `.cursor/rules`, and **the canonical verify command** (see [reference.md](reference.md)).
3. If the repo has no `scripts/verify.sh` (or equivalent), create one that runs the same checks as CI, or document the exact commands in `AGENTS.md` before heavy implementation.

## Artifacts

| Artifact | Template (next to this `SKILL.md`) |
|----------|--------------------------------------|
| Plan | `templates/PLAN.template.md` |
| PR body | `templates/PR.template.md` |

## Confidence score

Maintain a running score using the rules in [reference.md](reference.md). After each major step, output a short **Confidence block**:

```markdown
**Confidence: 0.62** — [one-line reason]
**Escalation: none** | **required** — [if required, why]
```

## Pipeline (strict order)

Copy this checklist into the reply and update checkboxes as you go.

```text
Pipeline progress:
- [ ] 1. Intake — task normalized, branch name chosen
- [ ] 2. Plan drafted (use PLAN template)
- [ ] 3. GATE — plan approved by human (STOP until approved)
- [ ] 4. Implement — branch, commits, minimal scope
- [ ] 5. Verify — project verify script / CI-parity commands
- [ ] 6. Docs — only if behavior/API/public surface changed
- [ ] 7. GATE — PR approved by human (STOP until approved)
- [ ] 8. Push + `gh pr create` (GitHub)
```

### Step 1 — Intake

- Restate the goal, acceptance criteria, and **out of scope**.
- Propose branch name: `agent/<short-slug>-<YYYYMMDD>` or team convention.
- Set initial confidence per reference (plan not written yet: use “intake only” band).

### Step 2 — Plan

Fill `PLAN.template.md`. Include: steps, files/modules likely touched, **test strategy**, risks, and **definition of done**.

### Step 3 — GATE (plan)

**Stop.** Present the full plan. Ask for explicit approval or edits. Do not write production code until the user approves.

### Step 4 — Implement

- Work on the approved branch.
- Match project style; no drive-by refactors.
- If verification fails later, prefer **targeted fixes**; track **failure counts** for escalation.

### Step 5 — Verify

- Run the repo’s **single** verify entrypoint (e.g. `./scripts/verify.sh`).
- Record pass/fail and logs (summarize, don’t paste huge logs unless asked).

### Step 6 — Docs

- If user-visible behavior or public API changed: update the **smallest** correct doc set (README section, `docs/`, ADR only if architectural).
- If no doc impact: state “no doc changes.”

### Step 7 — GATE (PR)

**Stop.** Present: summary, files changed, test results, doc delta, risks. Wait for approval to **open** the PR (or to mark ready for review).

### Step 8 — GitHub PR

- Push branch: `git push -u origin <branch>`.
- Create PR: `gh pr create` with body from `PR.template.md`.
- If `gh` is unavailable, give exact commands and the filled PR body for manual creation.

## Escalation (mandatory stop)

When any rule in [reference.md](reference.md) triggers:

1. Set **Escalation: required**.
2. Summarize: goal, attempts, **same failure count**, **total failure count**, current confidence.
3. Offer 2–3 options (e.g. narrow scope, spike, different approach, human provides missing fact).
4. **Do not** loop blindly on the same error.

## GitHub

- Use **`gh`** CLI when installed; otherwise document manual steps.
- Base branch: default `main` unless the repo uses another default (check with `git symbolic-ref refs/remotes/origin/HEAD` or project docs).

## Additional detail

- Numeric thresholds, confidence deltas, and verify contract: [reference.md](reference.md)
