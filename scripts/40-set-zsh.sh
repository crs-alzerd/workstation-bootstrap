#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting zsh as default shell..."

if ! command -v zsh >/dev/null 2>&1; then
  echo "ERROR: zsh not found. Install zsh first."
  exit 1
fi

ZSH_PATH="$(command -v zsh)"

if [[ "$SHELL" == "$ZSH_PATH" ]]; then
  echo "==> zsh is already the default shell"
  exit 0
fi

echo "Current shell: $SHELL"
echo "New shell:     $ZSH_PATH"

chsh -s "$ZSH_PATH"

echo "==> Default shell changed. Log out and log back in to apply."
