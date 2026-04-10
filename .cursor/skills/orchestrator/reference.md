# Orchestrator — reference

Numeric and policy detail for the **orchestrator** skill. Behavioral steps live in `SKILL.md`.

## Confidence score

Scale **0.0–1.0**: subjective **likelihood the change is merge-ready without surprises**, not a statistical measure.

### Bands

| Band | Range | Meaning |
|------|-------|---------|
| High | ≥ 0.65 | Plan clear, verify green or minor issues, scope controlled |
| Medium | 0.45–0.64 | Some unknowns, or verify flaky once, or moderate scope |
| Low | 0.25–0.44 | Repeated failures, ambiguous requirements, or large unexpected diff |
| Critical | < 0.25 | Wrong approach likely; stop and escalate |

### Initial value (plan written, before implementation)

| Situation | Value |
|-----------|--------|
| Plan concrete; test strategy matches repo; risks mitigated | **0.72** |
| Plan ok but meaningful unknowns (new area, integration risk) | **0.55** |
| Plan thin, fuzzy acceptance criteria, or missing verify path | **0.40** |

### Delta after each verify attempt

| Event | Delta |
|-------|--------|
| Full verify passed | **+0.08** |
| Verify passed after a **small** fix (one focused edit) | **+0.04** |
| Verify failed (tests/lint/typecheck/build) | **−0.12** |
| Verify failed, clearly **environmental** (document; ask human if persists) | **−0.06** |
| **Same root cause** as previous failure | **−0.15** |

Clamp to **[0.0, 1.0]**.

## Escalation

### Triggers (any one → mandatory stop)

1. **Same root cause** fails **3** consecutive verify attempts (count only when error **class** matches the previous attempt).
2. **Total** verify failures **≥ 5** this task (even if causes alternate).
3. Confidence **≤ 0.34** after a verify attempt.
4. **Blocked**: missing secret, prod access, policy, or unsafe to proceed.

### On escalation

Output: current confidence, both failure counts, last error **class** summary, and **2–3** options (e.g. narrow scope, spike, different approach, human supplies missing fact). **Do not** retry the same fix blindly.

### Failure class (for “same root cause”)

- **Same failure**: same error class (e.g. same test + assertion, or same linter rule + file).
- Reset **consecutive same-failure** counter when the error class changes.

## Human gates

| Gate | Rule |
|------|------|
| **After plan** | No implementation until the user explicitly approves the plan (or agreed edits). |
| **Before PR** | **None** in the default skill — push/open PR without a second chat stop; review on GitHub. |

Optional `gates.require_pr_approval` in `pipeline.config.yaml` is for **custom tooling**; the example config sets it `false`.

## Agent permissions

Orchestrators need **non-interactive** approval for routine shell use.

| Layer | What to adjust |
|-------|----------------|
| **Cursor CLI** | `~/.cursor/cli-config.json` — `permissions.allow` patterns (e.g. `Shell(**)` only on **trusted** machines/repos), or `approvalMode`. |
| **Project** | `.cursor/cli.json` merged from repo root (deeper wins). |
| **Cursor IDE** | Agent settings: auto-run / sandbox / terminal approval so verify and basic navigation are not blocked every time. |

Treat broad `Shell(**)` as full shell access.

## Subagent routing (Cursor Task tool)

The orchestrator uses Cursor’s **Task** tool to spawn sub-agents. Available types vary by product version; treat this table as **routing guidance**, not a guarantee every flag exists in your build.

| `subagent_type` | Use when | Typical model | Notes |
|-----------------|----------|---------------|--------|
| **explore** | Read-only codebase search, mapping callers, “where is X?” | Prefer **fast** | Set **`readonly: true`** when available so exploration cannot silently change files. |
| **shell** | Long verify loops, install scripts, heavy CLI triage | **fast** unless debugging a subtle failure | Good for noisy output the orchestrator should not absorb. |
| **generalPurpose** | Multi-step implementation or refactor that needs write + reasoning | Default / capable | Use a **tight** handoff packet; one clear outcome per Task. |
| **best-of-n-runner** | You want **parallel** attempts (e.g. two solution strategies) without polluting the main working tree | Same tier as workers | Each attempt gets an **isolated git worktree**; choose one winner, then integrate in the orchestrator thread. |

**Cost and context tactics**

| Tactic | Why |
|--------|-----|
| Prefer **explore** + **fast** for discovery | Cheaper; keeps write operations in the orchestrator or a single implementation Task. |
| One Task = one **bounded outcome** | Avoids unbounded context growth and repeated re-planning inside the worker. |
| **Summaries in, details on demand** | Workers return structured summaries; orchestrator asks for file excerpts only when stuck. |
| **New Task for new phase** | After plan approval, implementation can be one or several Tasks by milestone — not one mega-session. |
| **Background** only when you can **poll** | Don’t lose track of workers; merge results explicitly into confidence and branch state. |

## Sandbox and isolation

“Sandbox” in agent engineering is **layered**:

1. **Product sandbox** — Cursor’s terminal/sandbox and permission prompts (see [Agent permissions](#agent-permissions)). Tune so `./scripts/verify.sh` and normal dev commands run without blocking every line.
2. **Logical isolation** — Sub-agents run in a **separate context** from this chat: tool noise and long searches live there, not in the orchestrator transcript.
3. **Read-only workers** — `explore` + `readonly` prevents accidental writes during research.
4. **Git worktree isolation** — `best-of-n-runner` (when available) isolates risky or competing edits until you pick a winner.

Nothing here replaces **code review** or **CI**; it reduces accidental damage and keeps the orchestrator’s context usable on **long-lived** tasks.

## Verify contract (consumer repos)

Expose **one** command that matches CI:

- Preferred: `scripts/verify.sh` (executable) from repo root.
- Alternatives: `make ci`, `pnpm run verify` — must be in `AGENTS.md` or README.

The orchestrator uses that entrypoint for verify unless the user specifies otherwise for one run.

## GitHub CLI

```bash
gh pr create --base <branch> --head <branch> --title "..." --body-file ...
```

Draft: add `--draft` when the user wants it.

## Optional `pipeline.config.yaml`

At app repo root: overrides **confidence** bands/deltas, **escalation** thresholds, **default base branch**, **`verify.command`**, optional **`gates`**. Start from `pipeline.config.example.yaml` in the kit. If missing, use this file’s defaults.
