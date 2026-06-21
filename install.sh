#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACMAN_PACKAGES_FILE="$REPO_DIR/packages/pacman.txt"

log() {
  echo "==> $*"
}

warn() {
  echo "warning: $*" >&2
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

check_system() {
  log "Checking system..."

  require_command pacman
  require_command sudo
  require_command sed
  require_command awk

  if [[ ! -f /etc/arch-release ]]; then
    die "this script is intended for Arch/CachyOS-like systems"
  fi

  if [[ ! -f "$PACMAN_PACKAGES_FILE" ]]; then
    die "package file not found: $PACMAN_PACKAGES_FILE"
  fi

  log "System check OK"
}

read_pacman_packages() {
  local file="$1"
  local line

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove Windows CRLF if file was edited on Windows
    line="${line//$'\r'/}"

    # Remove full-line and inline comments
    line="$(printf '%s\n' "$line" | sed -E 's/[[:space:]]*#.*$//')"

    # Trim whitespace
    line="$(printf '%s\n' "$line" | awk '{$1=$1; print}')"

    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Avoid pacman provider prompt:
    # cargo is a virtual target provided by rust and rustup.
    # For workstation bootstrap rustup is usually the better choice.
    if [[ "$line" == "cargo" ]]; then
      warn "package target 'cargo' is virtual; replacing it with 'rustup'"
      line="rustup"
    fi

    printf '%s\n' "$line"
  done < "$file" | awk '!seen[$0]++'
}

validate_pacman_packages() {
  local -n packages_ref="$1"
  local missing=()
  local pkg

  log "Validating pacman package names..."

  for pkg in "${packages_ref[@]}"; do
    if ! pacman -Si "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    echo
    echo "The following packages were not found in enabled pacman repositories:"
    printf '  - %s\n' "${missing[@]}"
    echo
    echo "Fix packages/pacman.txt or move these packages to a future AUR/Flatpak installer."
    echo
    die "pacman package validation failed"
  fi

  log "Package validation OK"
}

install_pacman_packages() {
  local packages=()

  log "Installing pacman packages..."
  log "Reading package list from $PACMAN_PACKAGES_FILE"

  mapfile -t packages < <(read_pacman_packages "$PACMAN_PACKAGES_FILE")

  if (( ${#packages[@]} == 0 )); then
    warn "no pacman packages found in $PACMAN_PACKAGES_FILE"
    return 0
  fi

  log "Packages to install:"
  printf '  %s\n' "${packages[@]}"

  validate_pacman_packages packages

  log "Updating system and installing packages..."
  sudo pacman -Syu --needed "${packages[@]}"
}

main() {
  log "Workstation bootstrap started"

  check_system
  install_pacman_packages

  log "Workstation bootstrap finished"
}

main "$@"
