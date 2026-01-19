#!/bin/bash

# Ensure we're authenticated once and keep sudo alive
function keepsudoalive() {
  sudo -v

  # Keep the timestamp fresh until the script exits
  while true; do
    sleep 30
    sudo -n -v >/dev/null 2>&1 || break
  done &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null; sudo -k' EXIT
}

# -----------------------
# UI
# -----------------------
function colour_echo() {
  local colour="$1"; shift
  case "$colour" in
    red) echo -e "\033[31m$*\033[0m" ;;
    green) echo -e "\033[32m$*\033[0m" ;;
    yellow) echo -e "\033[33m$*\033[0m" ;;
    blue) echo -e "\033[34m$*\033[0m" ;;
    cyan) echo -e "\033[36m$*\033[0m" ;;
    *) echo "$*" ;;
  esac
}

function spinner() {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while kill -0 $pid 2>/dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# -----------------------------
# Helpers
# -----------------------------
have() { command -v "$1" >/dev/null 2>&1; }

append_once() {
  local line="$1" file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

add_or_replace_alias() {
  local name="$1" value="$2" file="$3"
  touch "$file"
  # delete existing alias line(s) for this name
  sed -i "/^alias[[:space:]]\+$name=/d" "$file"
  printf "alias %s='%s'\n" "$name" "$value" >> "$file"
}

remove_alias() {
  local name="$1" file="$2"
  touch "$file"
  sed -i "/^alias[[:space:]]\+$name=/d" "$file"
}

require_apt() {
  # Install (idempotent). Accepts many packages.
  sudo apt-get update -y >/dev/null 2>&1
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
}

system_arch() {
  local arch
  arch="$(uname -m 2>/dev/null || echo unknown)"
  case "$arch" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    *) echo "$arch" ;;
  esac
}
