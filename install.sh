#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Ariadne locations
export ARI_PATH="$HOME/.local/share/ariadne"
export ARI_INSTALL="$ARI_PATH/install"
export ARI_ASSETS="$ARI_INSTALL/assets"
export PATH="$ARI_PATH/bin:$PATH"
export BASHRC="$HOME/.bashrc"

# Ensure .bashrc exists
touch "$BASHRC"

# Load helpers
source "$ARI_INSTALL/helpers.sh"
source "$ARI_INSTALL/menu.sh"

# Load component installers
source "$ARI_INSTALL/components/core.sh"
source "$ARI_INSTALL/components/shell.sh"
source "$ARI_INSTALL/components/tools.sh"
source "$ARI_INSTALL/components/python.sh"
source "$ARI_INSTALL/components/node.sh"
source "$ARI_INSTALL/git-setup.sh"

# ---------------------------------------------------------
# Show menu and get selections
# ---------------------------------------------------------
echo "Select which tools to install:"
echo
SELECTED=$(show_menu)

if [ "$SELECTED" = "CANCELLED" ]; then
  echo "Installation cancelled."
  exit 0
fi

echo
echo "Selected tools: $SELECTED"
echo

# ---------------------------------------------------------
# Confirm installation
# ---------------------------------------------------------
read -rp "Install Ariadne with selected tools? [Y/n]: " install_answer
install_answer="${install_answer:-Y}"
case "$install_answer" in
  [Yy]*)
    echo
    ;;
  [Nn]*)
    echo "Installation cancelled."
    exit 0
    ;;
  *)
    echo "Unrecognised response '$install_answer'. Aborting."
    exit 1
    ;;
esac

# ---------------------------------------------------------
# Configure Git identity
# ---------------------------------------------------------
echo "Configuring Git user details (used for commits)."
configure_git_identity

keepsudoalive

# -----------------------------
# System updates
# -----------------------------
colour_echo cyan "Updating system packages..."
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# -----------------------------
# Core packages (always installed)
# -----------------------------
install_core_packages

# -----------------------------
# Selected tools
# -----------------------------
if is_selected "starship" "$SELECTED" || is_selected "zoxide" "$SELECTED" || is_selected "eza" "$SELECTED"; then
  setup_shell_environment "$SELECTED"
fi

if is_selected "bat" "$SELECTED"; then
  setup_bat
fi

if is_selected "ripgrep" "$SELECTED"; then
  install_ripgrep
fi

if is_selected "fd" "$SELECTED"; then
  install_fd
fi

if is_selected "fzf" "$SELECTED"; then
  install_fzf
fi

if is_selected "neovim" "$SELECTED"; then
  install_neovim
fi

if is_selected "lazygit" "$SELECTED"; then
  install_lazygit
fi

if is_selected "python" "$SELECTED"; then
  install_python_tooling
fi

if is_selected "node" "$SELECTED"; then
  install_node_tooling
fi

# -----------------------------
# Install Ariadne bin scripts
# -----------------------------
install_ari_bin_scripts
ensure_ari_splash

# -----------------------------
# Final setup
# -----------------------------
echo
echo
colour_echo green "Setup complete!"
echo
echo "Open a NEW terminal or run: source ~/.bashrc"
echo
echo "Available commands:"
echo "  ari-theme    - Change prompt colours"
echo "  shortcuts    - Show available shortcuts"
echo
echo "Documentation: https://thomasrice.com/ariadne"
echo
