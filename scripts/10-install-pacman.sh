#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_FILE="$REPO_DIR/packages/pacman.txt"

echo "==> Installing pacman packages..."

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "ERROR: package file not found: $PACKAGE_FILE"
  exit 1
fi

echo "==> Updating system and installing packages from $PACKAGE_FILE"
sudo pacman -Syu --needed - <"$PACKAGE_FILE"

echo "==> Pacman packages installed"
