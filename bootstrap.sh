#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

CYAN=$'\033[36m'
RESET=$'\033[0m'

clear
printf '%s' "$CYAN"
cat << 'BANNER'
   ▄████████    ▄████████  ▄█     ▄████████ ████████▄  ███▄▄▄▄      ▄████████
  ███    ███   ███    ███ ███    ███    ███ ███   ▀███ ███▀▀▀██▄   ███    ███
  ███    ███   ███    ███ ███▌   ███    ███ ███    ███ ███   ███   ███    █▀
  ███    ███  ▄███▄▄▄▄██▀ ███▌   ███    ███ ███    ███ ███   ███  ▄███▄▄▄
▀███████████ ▀▀███▀▀▀▀▀   ███▌ ▀███████████ ███    ███ ███   ███ ▀▀███▀▀▀
  ███    ███ ▀███████████ ███    ███    ███ ███    ███ ███   ███   ███    █▄
  ███    ███   ███    ███ ███    ███    ███ ███   ▄███ ███   ███   ███    ███
  ███    █▀    ███    ███ █▀     ███    █▀  ████████▀   ▀█   █▀    ██████████
               ███    ███
BANNER
printf '%s' "$RESET"

echo
echo "Ariadne - Your guide through the WSL labyrinth"
echo

REPO="https://github.com/thomasrice/ariadne-wsl.git"
DEST="$HOME/.local/share/ariadne"

if ! command -v git >/dev/null 2>&1; then
  echo "Git is required for installation and was not found."
  echo "Attempting to install git..."
  if ! sudo apt-get update -y || ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git; then
    echo "Could not install git automatically." >&2
    echo "Please run: sudo apt-get update && sudo apt-get install -y git" >&2
    exit 1
  fi
fi

echo "Setting up at: ${DEST}"
rm -rf "$DEST"

echo "Cloning Ariadne WSL..."
if ! git clone "$REPO" "$DEST" >/dev/null 2>&1; then
  echo "Failed to clone from ${REPO}." >&2
  echo "Check your internet connection and try again." >&2
  exit 1
fi

echo "Starting installation..."
echo
source "$DEST/install.sh"
