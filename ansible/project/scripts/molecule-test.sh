#!/usr/bin/env bash
#
# molecule-test.sh -- bootstrap a Python venv and run Molecule for a role.
# (System pip is locked down on this host, so we always use a venv.)
#
# Usage:
#   ./scripts/molecule-test.sh                 # 'molecule test' on role 'zsh'
#   ./scripts/molecule-test.sh zsh converge     # iterate without teardown
#   ./scripts/molecule-test.sh zsh login        # shell into the test instance
# -----------------------------------------------------------------------------
set -euo pipefail

ROLE="${1:-zsh}"
CMD="${2:-test}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="$PROJECT_DIR/.venv"

if [[ ! -d "$VENV" ]]; then
  echo ">> Creating venv at $VENV"
  python3 -m venv "$VENV"
fi
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install --quiet --upgrade pip
pip install --quiet -r "$PROJECT_DIR/molecule-requirements.txt"

ROLE_DIR="$PROJECT_DIR/roles/$ROLE"
if [[ ! -d "$ROLE_DIR/molecule" ]]; then
  echo "ERROR: no molecule scenario in $ROLE_DIR" >&2
  exit 1
fi
cd "$ROLE_DIR"
echo ">> molecule $CMD  (role: $ROLE)"
exec molecule "$CMD"
