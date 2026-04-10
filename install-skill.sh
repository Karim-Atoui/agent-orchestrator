#!/usr/bin/env bash
# Symlink dev-pipeline-orchestrator into a target repo's .cursor/skills/
# Usage: ./install-skill.sh /path/to/your/app

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${HERE}/.cursor/skills/dev-pipeline-orchestrator"

usage() {
  echo "Usage: $0 <path-to-target-repo>"
  echo "Creates: <target>/.cursor/skills/dev-pipeline-orchestrator -> ${SKILL_SRC}"
  exit 1
}

[[ $# -eq 1 ]] || usage
TARGET="$(cd "$1" && pwd)"
DEST_DIR="${TARGET}/.cursor/skills"
DEST="${DEST_DIR}/dev-pipeline-orchestrator"

[[ -d "$SKILL_SRC" ]] || { echo "Missing skill at $SKILL_SRC" >&2; exit 1; }

mkdir -p "$DEST_DIR"
if [[ -e "$DEST" ]] || [[ -L "$DEST" ]]; then
  echo "Already exists: $DEST — remove it first if you want to reinstall." >&2
  exit 1
fi

ln -s "$SKILL_SRC" "$DEST"
echo "Linked: $DEST -> $SKILL_SRC"
