#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking paru..."

if command -v paru >/dev/null 2>&1; then
  echo "==> paru already installed"
  exit 0
fi

echo "==> paru not found. Installing paru from AUR..."

sudo pacman -S --needed git base-devel

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

git clone https://aur.archlinux.org/paru.git "$TMP_DIR/paru"
cd "$TMP_DIR/paru"

makepkg -si

echo "==> paru installed"
