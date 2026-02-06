#!/bin/bash

# Note: We intentionally don't use set -e so the script continues past individual failures
# Failures are collected and reported at the end

# Reconnect stdin to terminal if running via pipe (e.g., curl | bash)
if [ ! -t 0 ]; then
  exec < /dev/tty
fi

# Track warnings for components that fail
WARNINGS=()

# Helper to run a component with error handling
# Usage: run_component "Name" function_name [args...]
run_component() {
  local name="$1"
  shift
  if ! "$@"; then
    WARNINGS+=("$name installation failed - you may need to install manually")
  fi
}

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
source "$ARI_INSTALL/components/ai-tools.sh"
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

# Auto-add dependencies for AI tools that need Node.js
if is_selected "claude-code" "$SELECTED" || is_selected "codex" "$SELECTED"; then
  if ! is_selected "node" "$SELECTED"; then
    echo "Note: Claude Code and Codex CLI require Node.js - adding to selection."
    SELECTED="$SELECTED node"
  fi
fi

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
# Configure Git identity (optional)
# ---------------------------------------------------------
echo "Git is a version control system used by developers to track code changes."
echo "If you plan to use Git, we can set up your name and email for commits."
echo
read -rp "Configure Git identity? [y/N]: " git_answer
case "$git_answer" in
  [Yy]*)
    configure_git_identity
    ;;
  *)
    echo "Skipping Git configuration. You can set this up later with:"
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"you@example.com\""
    echo
    ;;
esac

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
  run_component "Shell environment" setup_shell_environment "$SELECTED"
fi

if is_selected "bat" "$SELECTED"; then
  run_component "bat" setup_bat
fi

if is_selected "ripgrep" "$SELECTED"; then
  run_component "ripgrep" install_ripgrep
fi

if is_selected "fd" "$SELECTED"; then
  run_component "fd" install_fd
fi

if is_selected "fzf" "$SELECTED"; then
  run_component "fzf" install_fzf
fi

if is_selected "neovim" "$SELECTED"; then
  run_component "Neovim" install_neovim
fi

if is_selected "lazygit" "$SELECTED"; then
  run_component "LazyGit" install_lazygit
fi

if is_selected "python" "$SELECTED"; then
  run_component "Python tooling" install_python_tooling
fi

if is_selected "node" "$SELECTED"; then
  run_component "Node.js" install_node_tooling
fi

if is_selected "claude-code" "$SELECTED"; then
  run_component "Claude Code" install_claude_code
fi

if is_selected "opencode" "$SELECTED"; then
  run_component "OpenCode" install_opencode
fi

if is_selected "codex" "$SELECTED"; then
  run_component "Codex CLI" install_codex_cli
fi

# -----------------------------
# Install Ariadne bin scripts
# -----------------------------
install_ari_bin_scripts
ensure_ari_splash

# -----------------------------
# Final setup
# -----------------------------
# Try to initialize for current session
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)" 2>/dev/null || true
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash --cmd cd)" 2>/dev/null || true
fi

echo
echo
colour_echo green "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
colour_echo green "  Installation complete!"
colour_echo green "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Report any warnings
if [ ${#WARNINGS[@]} -gt 0 ]; then
  colour_echo yellow "Some components had issues:"
  for warning in "${WARNINGS[@]}"; do
    colour_echo yellow "  - $warning"
  done
  echo
fi

colour_echo cyan "Your terminal is now enhanced:"
is_selected "zoxide" "$SELECTED" && echo "  cd      - Smart navigation (remembers directories you visit)"
is_selected "eza" "$SELECTED" && echo "  ls      - File listing with icons and git status"
is_selected "bat" "$SELECTED" && echo "  cat     - Syntax highlighting"
echo
colour_echo cyan "Shortcuts:"
echo "  exp     - Open current directory in Windows Explorer"
echo "  open    - Open a file in its Windows app (e.g. open file.pdf)"
is_selected "lazygit" "$SELECTED" && echo "  lg      - LazyGit (terminal UI for git)"
is_selected "neovim" "$SELECTED" && echo "  n       - Neovim"

# Show AI tools if any were installed
if is_selected "claude-code" "$SELECTED" || is_selected "opencode" "$SELECTED" || is_selected "codex" "$SELECTED"; then
  echo
  colour_echo cyan "AI coding assistants:"
  is_selected "claude-code" "$SELECTED" && echo "  claude  - Claude Code (set ANTHROPIC_API_KEY first)"
  is_selected "opencode" "$SELECTED" && echo "  opencode - OpenCode (configure on first run)"
  is_selected "codex" "$SELECTED" && echo "  codex   - Codex CLI (set OPENAI_API_KEY first)"
fi

echo
colour_echo cyan "Ariadne:"
echo "  ari-theme   - Change your prompt colours"
echo "  shortcuts   - Show all available shortcuts"
echo
echo "Documentation: https://www.ariadne-wsl.com"
echo
colour_echo cyan "→ Close this terminal and open a new one to see your new prompt."
echo
