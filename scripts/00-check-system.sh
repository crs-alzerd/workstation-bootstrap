#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking system..."

if ! command -v pacman >/dev/null 2>&1; then
  echo "ERROR: pacman not found. This script is intended for Arch/CachyOS-like systems."
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "WARN: git not found. It will be installed by pacman script."
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "ERROR: sudo not found."
  exit 1
fi

echo "==> System check OK"
