#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_FILE="$REPO_DIR/packages/aur.txt"

echo "==> Installing AUR packages..."

if [[ ! -f "$PACKAGE_FILE" ]]; then
  echo "ERROR: package file not found: $PACKAGE_FILE"
  exit 1
fi

if ! command -v paru >/dev/null 2>&1; then
  echo "ERROR: paru not found. Run scripts/20-install-paru.sh first."
  exit 1
fi

echo "==> Installing packages from $PACKAGE_FILE"
echo "==> Review PKGBUILD changes when paru asks."

xargs -a "$PACKAGE_FILE" paru -S --needed

echo "==> AUR packages installed"
