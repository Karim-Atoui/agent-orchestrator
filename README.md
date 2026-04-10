# Dev pipeline orchestrator (Cursor)

Kit for running a **sequential** agent workflow: **intake → plan → approve plan → implement → verify → docs → approve PR → GitHub PR**, with **confidence scoring** and **escalation** when verification keeps failing.

## Contents

| Path | Purpose |
|------|---------|
| `.cursor/skills/dev-pipeline-orchestrator/` | Cursor skill (instructions + templates) |
| `pipeline.config.example.yaml` | Optional per-repo thresholds and verify command |
| `scripts/verify.contract.md` | What `scripts/verify.sh` should do in app repos |
| `scripts/verify.example.sh` | Stub to copy and replace in app repos |

## Slash command (all projects)

Global commands live in `~/.cursor/commands/*.md`. The name of the file (without `.md`) is the `/` command.

Install **`/orchestrate`** once on your machine:

```bash
cp /path/to/agent-orchestrator/.cursor/commands/orchestrate.md ~/.cursor/commands/orchestrate.md
```

In **Agent** chat, type **`/`** → **`orchestrate`** → edit **Goal** / issue / constraints in the inserted text (or send them in the next message). Reload Cursor if the command does not appear yet.

## Use in an application repository

1. **Copy the skill** into the app repo (pick one):

   - **Option A:** Copy the folder `.cursor/skills/dev-pipeline-orchestrator/` into your project’s `.cursor/skills/`.
   - **Option B:** From this repo, run `./install-skill.sh` with your project path to symlink the skill into that repo’s `.cursor/skills/` (see script help).

2. **Add a verify entrypoint** in the app repo, e.g. `scripts/verify.sh`, matching CI. See `scripts/verify.contract.md`.

3. **Optional:** Copy `pipeline.config.example.yaml` to `pipeline.config.yaml` at the app repo root and adjust. The skill uses it when present; otherwise it follows `reference.md` defaults.

4. **Document** the verify command in `AGENTS.md` or README so every agent run agrees on one command.

5. In Cursor, invoke the workflow by asking the agent to follow the **dev-pipeline-orchestrator** skill (or describe the pipeline in your own words; the skill description helps discovery).

## Human gates (enforced by the skill)

- Approval **after the plan**, before implementation.
- Approval **before opening the PR** (or before marking ready for review).

## Escalation

Stops and asks you when repeated verify failures or low confidence thresholds are hit (see `reference.md`).

## This repository

`AGENTS.md` describes how to maintain this kit. It is not an application runtime; it is documentation + Cursor assets you copy into real projects.
