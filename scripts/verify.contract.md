# Verify script contract (for application repositories)

The dev pipeline expects **one** command developers and agents run before a PR. It should match what CI runs (or the strictest subset that is practical locally).

## Requirements

1. **Exit code** — `0` means success; non-zero means failure (same as CI).
2. **Location** — Document in `AGENTS.md` or README. Recommended path: `scripts/verify.sh` from repo root.
3. **Idempotent** — Safe to run repeatedly.
4. **Fast enough** — Prefer parity with CI over skipping checks; if some CI steps are too heavy locally, document the gap in `AGENTS.md`.

## Example: Node / pnpm

```bash
#!/usr/bin/env bash
set -euo pipefail
pnpm install --frozen-lockfile
pnpm run lint
pnpm run test
pnpm run build
```

## Example: generic Makefile

```bash
#!/usr/bin/env bash
set -euo pipefail
make ci
```

## Wiring

- Add `pipeline.config.yaml` (see `pipeline.config.example.yaml` in the orchestrator kit) with `verify.command` if not using `./scripts/verify.sh`.
