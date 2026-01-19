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

echo "Setting up at: ${DEST}"
rm -rf "$DEST"

echo "Cloning Ariadne WSL..."
git clone "$REPO" "$DEST" >/dev/null 2>&1

echo "Starting installation..."
echo
source "$DEST/install.sh"
