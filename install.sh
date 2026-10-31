#!/usr/bin/env bash
# ThinkRice — Fastfetch dotfiles installer (curl/wget friendly)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/aaksaa/thinkrice/main/install.sh | bash
#   wget -qO- https://raw.githubusercontent.com/aaksaa/thinkrice/main/install.sh | bash
#
# Non-interactive:
#   THINKRICE_CONFIG=thinkpad-vertical.jsonc \
#     curl -fsSL <url> | bash

set -euo pipefail

REPO="aaksaa/thinkrice"
BRANCH="${THINKRICE_BRANCH:-main}"
TMP_DIR="$(mktemp -d)"
FASTFETCH_DIR="$HOME/.config/fastfetch"
FASTFETCH_ASCII_DIR="$FASTFETCH_DIR/ascii"
BACKUP_DIR="$HOME/.config/fastfetch-backup-$(date +%Y%m%d-%H%M%S)"
SELECTED_CONFIG="${THINKRICE_CONFIG:-}"

# Colors (only when stdout is a terminal)
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
  BLUE='\033[0;34m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi
info()   { echo -e "${BLUE}[INFO]${NC} $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
error()  { echo -e "${RED}[ERROR]${NC} $*" >&2; }
success(){ echo -e "${GREEN}[OK]${NC} $*"; }

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

# Ensure bash (e.g., if piped into sh by mistake)
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "This script requires bash. Try: curl -fsSL <url> | bash" >&2
  exit 1
fi

# Read user input even when the script is piped (stdin is the pipe)
read_input() {
  local __var="$1" __prompt="$2"
  if [[ -t 0 ]]; then
    read -rp "$__prompt" "$__var"
  elif [[ -r /dev/tty ]]; then
    read -rp "$__prompt" "$__var" < /dev/tty
  else
    error "No TTY for interactive input. Set THINKRICE_CONFIG=<name>.jsonc to run non-interactively."
    exit 1
  fi
}

# Download the repo tarball (main → master fallback)
download_repo() {
  local tarball="$TMP_DIR/thinkrice.tar.gz"
  local branches=("$BRANCH")
  [[ "$BRANCH" == "main" ]] && branches+=("master")

  command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 \
    || { error "Neither curl nor wget found."; exit 1; }

  info "Downloading ${REPO} tarball..."
  local ok=0 url b
  for b in "${branches[@]}"; do
    url="https://github.com/${REPO}/archive/refs/heads/${b}.tar.gz"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$url" -o "$tarball" && ok=1 && break
    else
      wget -qO "$tarball" "$url" && ok=1 && break
    fi
    warn "Branch '$b' not available, trying next..."
  done

  (( ok )) || { error "Failed to download repository."; exit 1; }

  mkdir -p "$TMP_DIR/repo"
  tar -xzf "$tarball" -C "$TMP_DIR/repo" --strip-components=1
  SRC_DIR="$TMP_DIR/repo"
  success "Repository downloaded."
}

# Let the user choose a config (or use THINKRICE_CONFIG)
pick_config() {
  local configs_dir="$SRC_DIR/fastfetch/configs"
  [[ -d "$configs_dir" ]] || { error "fastfetch/configs not found in repository."; exit 1; }

  local configs=() f
  while IFS= read -r -d '' f; do
    configs+=("$(basename "$f")")
  done < <(find "$configs_dir" -maxdepth 1 -name '*.jsonc' -print0 | sort -z)

  [[ ${#configs[@]} -eq 0 ]] && { error "No .jsonc configs found."; exit 1; }

  # Non-interactive path
  if [[ -n "$SELECTED_CONFIG" ]]; then
    local c match=""
    for c in "${configs[@]}"; do
      [[ "$c" == "$SELECTED_CONFIG" ]] && match="$c" && break
    done
    [[ -z "$match" ]] && { error "Config '$SELECTED_CONFIG' not found. Available: ${configs[*]}"; exit 1; }
    SELECTED_CONFIG="$match"
    success "Using config from THINKRICE_CONFIG: $SELECTED_CONFIG"
    return
  fi

  echo
  info "Available Fastfetch configurations:"
  local i=1
  for c in "${configs[@]}"; do
    printf "  %2d) %s\n" "$i" "$c"
    ((i++))
  done

  local choice
  while true; do
    read_input choice "Choose a config [1-${#configs[@]}]: "
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#configs[@]} )); then
      break
    fi
    warn "Invalid choice, try again."
  done
  SELECTED_CONFIG="${configs[$((choice-1))]}"
  success "Selected config: $SELECTED_CONFIG"
}

# Install config.jsonc + copy all ASCII logos
apply_config() {
  local src_configs="$SRC_DIR/fastfetch/configs"
  local src_ascii="$SRC_DIR/fastfetch/ascii"

  mkdir -p "$FASTFETCH_DIR" "$FASTFETCH_ASCII_DIR"

  if [[ -f "$FASTFETCH_DIR/config.jsonc" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp "$FASTFETCH_DIR/config.jsonc" "$BACKUP_DIR/config.jsonc"
    warn "Existing config backed up to: $BACKUP_DIR/config.jsonc"
  fi

  cp "$src_configs/$SELECTED_CONFIG" "$FASTFETCH_DIR/config.jsonc"
  success "Installed: ~/.config/fastfetch/config.jsonc (from $SELECTED_CONFIG)"

  if [[ -d "$src_ascii" ]]; then
    cp -r "$src_ascii/." "$FASTFETCH_ASCII_DIR/"
    local n; n="$(find "$FASTFETCH_ASCII_DIR" -maxdepth 1 -type f | wc -l)"
    success "Copied all ASCII logos to ~/.config/fastfetch/ascii/ ($n files)"
  else
    warn "fastfetch/ascii not found, skipping ASCII copy."
  fi
}

main() {
  echo "=========================================="
  echo "  ThinkRice — Fastfetch Dotfiles Installer"
  echo "  ${REPO}"
  echo "=========================================="
  echo

  download_repo
  pick_config
  apply_config

  echo
  success "Done! Run: fastfetch"
  [[ -d "$BACKUP_DIR" ]] && info "Backup: $BACKUP_DIR"
  command -v fastfetch >/dev/null 2>&1 \
    || warn "fastfetch is not installed — install it via your package manager."
}

main "$@"