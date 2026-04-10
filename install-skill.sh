#!/usr/bin/env bash
# Symlink this repo's orchestrator skill into Cursor skills.
#
# Usage:
#   ./install-skill.sh              → ~/.cursor/skills/orchestrator (global, every workspace)
#   ./install-skill.sh /path/to/app → <app>/.cursor/skills/orchestrator (project-only)

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${HERE}/.cursor/skills/orchestrator"

usage() {
  echo "Usage: $0 [path-to-target-repo]"
  echo "  (no args)  → symlinks to \${HOME}/.cursor/skills/orchestrator"
  echo "  <path>     → symlinks to <path>/.cursor/skills/orchestrator"
  exit 1
}

[[ -d "$SKILL_SRC" ]] || { echo "Missing skill at $SKILL_SRC" >&2; exit 1; }

if [[ $# -eq 0 ]]; then
  DEST_DIR="${HOME}/.cursor/skills"
  DEST="${DEST_DIR}/orchestrator"
elif [[ $# -eq 1 ]]; then
  TARGET="$(cd "$1" && pwd)"
  DEST_DIR="${TARGET}/.cursor/skills"
  DEST="${DEST_DIR}/orchestrator"
else
  usage
fi

mkdir -p "$DEST_DIR"
if [[ -e "$DEST" ]] || [[ -L "$DEST" ]]; then
  echo "Already exists: $DEST — remove it first if you want to reinstall." >&2
  exit 1
fi

ln -s "$SKILL_SRC" "$DEST"
echo "Linked: $DEST -> $SKILL_SRC"
