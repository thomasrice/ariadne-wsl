#!/bin/bash

# Install Python tooling
install_python_tooling() {
  colour_echo cyan "Installing Python tools (uv + poetry)..."

  # Ensure python3 is available
  require_apt python3

  # Create alias for python -> python3
  add_or_replace_alias python "python3" "$BASHRC"

  # Install uv via the official installer (avoids PEP 668 issues)
  if ! have uv; then
    colour_echo cyan "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh

    # Add uv to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    append_once 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC"
  fi

  # Install poetry using uv (avoids PEP 668 externally-managed-environment error)
  if have uv; then
    if uv tool list | grep -q '^poetry '; then
      colour_echo cyan "Poetry already installed, upgrading via uv..."
      uv tool upgrade poetry
    else
      colour_echo cyan "Installing poetry via uv..."
      uv tool install poetry
    fi
  else
    colour_echo yellow "uv not available, skipping poetry installation"
    return 1
  fi

  echo "Python tooling installed: uv, poetry"
}
