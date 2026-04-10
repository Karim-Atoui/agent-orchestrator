# Dev pipeline — reference

## Confidence score

Scale **0.0–1.0**: subjective estimate of **likelihood the change is merge-ready without surprises**, not a statistical measure.

### Bands

| Band | Range | Meaning |
|------|-------|---------|
| High | ≥ 0.65 | Plan clear, verify green or minor issues, scope controlled |
| Medium | 0.45–0.64 | Some unknowns, or verify flaky once, or moderate scope |
| Low | 0.25–0.44 | Repeated failures, ambiguous requirements, or large unexpected diff |
| Critical | < 0.25 | Wrong approach likely; stop and escalate |

### Initial value (after plan is written, before implementation)

- **0.72** — Plan is concrete; test strategy matches repo; risks listed with mitigations.
- **0.55** — Plan ok but meaningful unknowns (new area of codebase, integration risk).
- **0.40** — Plan thin, unclear acceptance criteria, or missing verify path.

### Adjust after each verify attempt

- **+0.08** — Full verify passed.
- **+0.04** — Verify passed after a **small** fix (one focused edit).
- **−0.12** — Verify failed (tests/lint/typecheck/build).
- **−0.06** — Verify failed but failure is clearly environmental (document and ask human if persists).
- **−0.15** — Same root cause as previous failure (duplicate failure).

Clamp to **[0.0, 1.0]**.

## Escalation rules (human must decide)

Escalate when **any** of:

1. **Same root cause** fails **3** consecutive verify attempts (adjust counter only when the error class matches).
2. **Total** verify failures **≥ 5** in this task (even if alternating causes).
3. Confidence **≤ 0.34** after a verify attempt.
4. **Blocked** on missing secret, prod access, or policy (cannot proceed safely).

On escalation: output confidence, counts, last error summary, and options; **do not** retry the same fix blindly.

## Human gates (non-optional)

1. **After plan** — No implementation until explicit user approval of the plan artifact.
2. **Before PR** — User approves opening the PR (or marking ready). Include summary + test evidence + doc delta.

## Verify contract (consumer repos)

Each application repo should expose **one** command that matches CI:

- Preferred: `scripts/verify.sh` (executable) from repo root.
- Alternative: `make ci` or `pnpm run verify` — must be documented in `AGENTS.md` or README.

The orchestrator **always** uses that entry point for step 5 unless the user specifies otherwise for one run.

## Failure counting

- **Same failure**: same error message class (e.g. same test name + same assertion, or same linter rule id + same file).
- Reset “consecutive same failure” counter when the error class changes.

## GitHub CLI

- `gh pr create --base <branch> --head <branch> --title "..." --body-file ...`
- Use draft: `--draft` if the user wants a draft first.

## Optional `pipeline.config.yaml`

If the target repo contains `pipeline.config.yaml` at its root, use it to override defaults for **confidence initial bands**, **escalation thresholds**, **default base branch**, and **`verify.command`**. Copy `pipeline.config.example.yaml` from the orchestrator kit as a starting point. If the file is missing, use the defaults documented in this file.
