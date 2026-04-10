# Orchestrator (Cursor)

Sequential agent workflow: **intake → plan → approve plan → implement → verify → docs → GitHub PR**, with **confidence scoring** and **escalation** on repeated verify failures. The orchestrator is **thin**: heavy exploration, verify triage, and large edits are delegated to Cursor **Task** sub-agents (separate context, optional read-only or worktree isolation) so long tasks stay manageable and costs stay controlled.

Full behavior: `SKILL.md` inside the skill folder; numbers and Task routing: `reference.md` in the same folder.

## Contents

| Path | Purpose |
|------|---------|
| `.cursor/skills/orchestrator/` | Skill (`SKILL.md`, `reference.md`, templates) |
| `.cursor/commands/orchestrate.md` | Thin `/orchestrate` entry — points at the skill |
| `pipeline.config.example.yaml` | Optional per-repo overrides |
| `scripts/verify.contract.md` | Contract for `scripts/verify.sh` in app repos |
| `scripts/verify.example.sh` | Stub to copy |

## Install once (every workspace)

Put the skill in your **user** skills directory so Cursor loads it for **any** folder you open — no per-project copy.

From a clone of this repo:

```bash
./install-skill.sh
```

That symlinks this repository’s `.cursor/skills/orchestrator` to `~/.cursor/skills/orchestrator`. Re-run after you `git pull` the kit if you want the symlink to keep pointing at this clone (or copy the folder instead of symlinking if you prefer a snapshot).

Slash commands are user-scoped too. Install the entry once:

```bash
cp /path/to/this-kit/.cursor/commands/orchestrate.md ~/.cursor/commands/orchestrate.md
```

In Agent chat: **`/`** → **`orchestrate`** → fill Goal / issue / constraints. Reload Cursor if the command does not appear.

### Optional: pin a version in one repo

To ship a **fixed** skill revision with a team repo, symlink or copy `.cursor/skills/orchestrator` into that repo’s `.cursor/skills/` (see `./install-skill.sh /path/to/repo`). User-level skills still apply unless you rely on project-only overrides.

## One orchestrator vs many skills

**You can have both.** A common pattern:

- **One `orchestrator` skill** — owns the end-to-end pipeline, gates, confidence, and when to spawn Task workers.
- **Additional skills** — narrow domains (e.g. “code review rubric”, “release notes”, “migrations checklist”) that are **small and reusable**. The orchestrator can say “follow the X skill for step Y” or you invoke them directly with `/` when you do not need the full pipeline.

Avoid making **every** skill a separate “orchestrator” — you get competing workflows and unclear ownership. Prefer **one coordinator** plus **specialists** (or Task sub-agents inside the pipeline) unless a domain is truly standalone.

## Use in an application repo

1. **Prefer** user install above so you do not duplicate the skill.
2. Add `scripts/verify.sh` (or equivalent) matching CI; document in `AGENTS.md`.
3. Optionally copy `pipeline.config.example.yaml` → `pipeline.config.yaml` at repo root.

## Human gate

One gate: **approval after plan**, before implementation. No second gate before push; review on GitHub.

## This repository

Kit only — not a runtime. Maintainer notes: `AGENTS.md`.
