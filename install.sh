#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Workstation bootstrap started"

"$REPO_DIR/scripts/00-check-system.sh"
"$REPO_DIR/scripts/10-install-pacman.sh"
"$REPO_DIR/scripts/20-install-paru.sh"
"$REPO_DIR/scripts/30-install-aur.sh"
"$REPO_DIR/scripts/40-set-zsh.sh"

echo "==> Workstation bootstrap completed"
echo "==> Next stage later: GNU Stow configs and application settings"
