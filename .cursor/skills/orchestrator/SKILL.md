---
name: orchestrate
description: >-
  Runs a sequential software delivery pipeline from task intake through plan approval,
  implementation, verification, documentation updates, and GitHub PR—with confidence
  tracking and human escalation. Uses Cursor Task sub-agents (explore, shell, workers)
  for heavy or parallel work so the main thread stays small. Use when the user invokes
  /orchestrate, wants an orchestrated dev workflow, multi-agent delegation, or a plan
  gate before implementation.
---

# Orchestrator

## `/orchestrate` (slash entry)

**Skill resolution** — Cursor merges:

- **User (default):** `~/.cursor/skills/orchestrator/`
- **Project override:** `.cursor/skills/orchestrator/` in the repo

**Do not duplicate** steps or numbers outside this file and `reference.md` — they are the single source of truth.

### Task (user — keep or replace)

**Goal:**

**GitHub issue (optional):**

**Constraints (optional):**

### Instruction

Run this pipeline **end-to-end** for this workspace until it completes or you hit a mandatory stop (plan gate, escalation, or user interrupt).

## Role

You are the **orchestrator** in this chat: you own **human gates**, **confidence**, **escalation**, and **handoffs**. Sub-agents run **bounded** implementation or verify work when that keeps context small (see [Multi-agent execution](#multi-agent-execution-cursor)).

## Principles

1. **Sequential phases** — Do not skip or reorder phases. No production code before the plan gate.
2. **One verify entrypoint** — Use the repo’s canonical command (see [reference.md](reference.md)); do not invent ad-hoc checks unless the user overrides for a single run.
3. **Minimal scope** — Match project style; no unrelated refactors.
4. **Clarity before commitment** — If requirements are ambiguous, **stop and ask** before the plan is treated as final.
5. **Observable progress** — After each major phase transition, emit a [Confidence block](#confidence-and-escalation).
6. **Thin orchestrator, fat workers** — Keep *this* chat focused on decisions, gates, and short summaries. Offload exploration, noisy verify loops, and large edits to **Task** sub-agents per [Multi-agent execution](#multi-agent-execution-cursor).
7. **Cost-aware routing** — Use cheaper/faster sub-agent profiles for read-only search and bounded shell work; reserve the main agent for approval, ambiguous tradeoffs, and integration. See [reference.md — Subagent routing](reference.md#subagent-routing-cursor-task-tool).

## Tracked state

Maintain internally (update as you go; expose when useful or when escalating):

| Field | Notes |
|-------|--------|
| **Branch** | Agreed `agent/<slug>-<YYYYMMDD>` (or team convention). |
| **Confidence** | 0.0–1.0 per [reference.md](reference.md). |
| **Consecutive same-failure count** | Same *error class* as previous verify attempt; reset when the class changes. |
| **Total verify failures** | All failed verify attempts this task. |

Thresholds and deltas: [reference.md](reference.md).

## Artifacts

| Output | Template |
|--------|----------|
| Plan | `templates/PLAN.template.md` |
| PR body | `templates/PR.template.md` |

## Workflow

Copy into the reply and tick as you go:

```text
Pipeline:
- [ ] 1. Intake
- [ ] 2. Plan (no unresolved ambiguity)
- [ ] 3. Gate — plan approved by human
- [ ] 4. Implement
- [ ] 5. Verify
- [ ] 6. Docs (if needed)
- [ ] 7. Push + PR (GitHub)
```

---

### 1. Intake

| | |
|--|--|
| **Do** | Restate goal, acceptance criteria, **out of scope**; propose branch name. |
| **Read** | `AGENTS.md`, `.cursor/rules`, verify command (see [reference.md](reference.md)). If `pipeline.config.yaml` exists at repo root, apply its overrides. |
| **Stop** | If workspace is not the target app repo — ask once to confirm root. |

---

### 2. Plan

| | |
|--|--|
| **Do** | Fill `PLAN.template.md` (approach, files, test strategy, risks, definition of done). |
| **Stop (mandatory)** | If anything material is **unclear or conflicting** (scope, acceptance criteria, approach, dependencies), **ask the human** and document clarifications in the plan. Do not call the plan “ready for approval” until resolved. |

---

### 3. Gate (plan)

| | |
|--|--|
| **Do** | Present the full plan; request explicit **approve** or **edit**. |
| **Stop** | **No implementation until approved.** |

---

### 4. Implement

| | |
|--|--|
| **Do** | Work on the approved branch only; match project conventions. Prefer **targeted** fixes if verify fails later. |
| **Delegation** | Use a **Task** sub-agent when scope is multi-file, exploratory, or log-heavy; stay inline for tiny edits ([Multi-agent execution](#multi-agent-execution-cursor)). |
| **Stop** | On escalation during verify (see below), not on first verify failure. |

---

### 5. Verify

| | |
|--|--|
| **Do** | Run the single verify entrypoint once per attempt; summarize pass/fail (avoid dumping full logs unless asked). |
| **Update** | Adjust confidence and failure counters per [reference.md](reference.md). |
| **Delegation** | Offload verify triage to a **Task** sub-agent if iteration would flood this chat with logs or tool noise. |
| **Stop** | When **escalation rules** in [reference.md](reference.md) fire — summarize, offer options, do not blindly repeat the same fix. |

---

### 6. Docs

| | |
|--|--|
| **Do** | Update docs only if user-visible behavior or public API changed; else state “no doc changes.” |
| **Delegation** | **Task** sub-agent for large doc sweeps; orchestrator for small edits. |

---

### 7. Push and PR

| | |
|--|--|
| **Do** | `git push -u origin <branch>`; `gh pr create` with `PR.template.md` body (draft if user prefers). If `gh` missing, give commands + pasted body. |
| **Note** | No second human gate before push; review happens on GitHub. |

---

## Multi-agent execution (Cursor)

This skill assumes the **Task** tool (sub-agents) is available: each worker runs with its **own context budget** and optional **read-only** or **worktree isolation**. That is how you match “sandboxed workers + long tasks + controlled cost” in Cursor — not by stuffing everything into one chat.

### When to spawn a Task vs stay inline

| Stay inline | Spawn a Task sub-agent |
|-------------|-------------------------|
| Single `./scripts/verify.sh` (or equivalent) with a manageable log | Repeated verify failures, log diving, or multi-step triage |
| Obvious edit in 1–2 files | Multi-file or exploratory implementation |
| Quick factual lookup | Broad codebase exploration (“where is X done?”) |
| You are at a **human gate** (plan approval) | Parallel experiments (see `best-of-n-runner` in [reference.md](reference.md)) |

**Routing** (which `subagent_type`, `readonly`, model): [reference.md — Subagent routing](reference.md#subagent-routing-cursor-task-tool).

### Handoff packet (required in every Task `prompt`)

Put this at the top of the sub-agent prompt so returns stay comparable:

```text
Role: <e.g. implementer | explorer | verify-triage>
Goal (1 paragraph) and branch: <name>
In scope / out of scope: <explicit>
Constraints: <user + AGENTS.md + anything fragile>
Verify command before return: <exact command; or "none" for read-only explore>
Return format:
  1) Summary (bullets)
  2) Files touched (paths)
  3) Verify result + error class if failed
  4) Open questions / risks (if any)
```

The orchestrator **reviews** the return only — not full tool transcripts — then updates confidence/counters and decides the next step.

### Long-running tasks

Long work should be **chunked**, not one endless sub-agent run.

1. **Milestones** — After each pipeline phase (or after a bounded verify loop), emit a short **checkpoint** in this chat: what landed, what is risky, what is next.
2. **Fresh workers for new chunks** — Prefer a new Task with a fresh prompt over an infinitely long worker session (context drifts; cost climbs).
3. **Background tasks** — For slow or parallel work, Task may run in the background; **poll to completion** before merging results into the plan or branch story.
4. **Summaries over transcripts** — Workers report outcomes and pointers (file:line); the orchestrator pulls details only when debugging.

### Sandbox and isolation (what “sandbox” means here)

| Layer | Purpose |
|-------|---------|
| **Cursor terminal / CLI sandbox** | Limits what shell commands can do without extra approval — configure so **verify** is non-interactive. See [reference.md — Agent permissions](reference.md#agent-permissions). |
| **`readonly` Task** | Explore agents that must not write — reduces risk and keeps merges explicit in the orchestrator thread. |
| **`best-of-n-runner`** | Optional: isolated **git worktrees** for parallel solution attempts; pick one winner before integrating. |

Details: [reference.md — Sandbox and isolation](reference.md#sandbox-and-isolation).

## Confidence and escalation

After each major phase transition (and after each verify attempt), output:

```markdown
**Confidence: 0.62** — [one-line reason]
**Escalation: none** | **required** — [if required, why]
```

Numeric bands, verify deltas, and **mandatory escalation triggers**: [reference.md](reference.md).

## Permissions

If routine shell use is blocked (e.g. every `cd` / `ls` prompts), the pipeline cannot run smoothly. Fix in Cursor CLI or IDE settings — [reference.md — Agent permissions](reference.md#agent-permissions).

## GitHub

Use **`gh`** when available. Default base branch `main` unless the repo or `pipeline.config.yaml` says otherwise (`git symbolic-ref refs/remotes/origin/HEAD` or docs).

## Further detail

All tables of thresholds, failure-class rules, verify contract, `pipeline.config.yaml` keys, and **Task/subagent routing**: **[reference.md](reference.md)**.
