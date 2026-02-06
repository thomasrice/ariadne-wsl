#!/bin/bash

# Install a global npm package, retrying with sudo on permission failures.
# Args: <npm_package> <expected_binary> <display_name>
install_npm_global_with_fallback() {
  local npm_package="$1"
  local expected_binary="$2"
  local display_name="$3"

  # Prefer user-local global installs to avoid system npm permission issues.
  mkdir -p "$HOME/.local"
  export PATH="$HOME/.local/bin:$PATH"
  append_once 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC"

  if npm install -g --prefix "$HOME/.local" "$npm_package"; then
    if have "$expected_binary"; then
      colour_echo green "$display_name installed!"
      return 0
    fi
  fi

  colour_echo yellow "$display_name user-local install failed. Retrying with sudo..."
  if ! sudo -n npm install -g "$npm_package"; then
    colour_echo yellow "$display_name installation failed (sudo retry was not available or failed)"
    echo "  Try manually: sudo npm install -g $npm_package"
    return 1
  fi

  if have "$expected_binary"; then
    colour_echo green "$display_name installed!"
    return 0
  fi

  colour_echo yellow "$display_name installed package but '$expected_binary' was not found on PATH"
  return 1
}

install_npm_binary_to_local() {
  local npm_package="$1"
  local expected_binary="$2"
  local display_name="$3"

  if install_npm_global_with_fallback "$npm_package" "$expected_binary" "$display_name"; then
    return 0
  fi

  # Final attempt with interactive sudo for environments without cached credentials.
  colour_echo yellow "$display_name final retry may prompt for sudo password..."
  if sudo npm install -g "$npm_package"; then
    if have "$expected_binary"; then
      colour_echo green "$display_name installed!"
      return 0
    else
      colour_echo yellow "$display_name installed package but '$expected_binary' was not found on PATH"
      return 1
    fi
  fi

  colour_echo yellow "$display_name installation failed"
  return 1
}

# Install Claude Code (Anthropic's AI coding assistant)
install_claude_code() {
  colour_echo cyan "Installing Claude Code..."

  if ! have npm; then
    colour_echo yellow "Node.js/npm not found. Please select 'Node.js' to install Claude Code."
    return 1
  fi

  if install_npm_binary_to_local "@anthropic-ai/claude-code" "claude" "Claude Code"; then
    echo "  Set ANTHROPIC_API_KEY from console.anthropic.com"
    return 0
  else
    colour_echo yellow "Claude Code installation failed"
    return 1
  fi
}

# Install OpenCode (open-source AI coding tool)
install_opencode() {
  colour_echo cyan "Installing OpenCode..."

  # Use the official install script (works without Node.js)
  if curl -fsSL https://opencode.ai/install | bash; then
    colour_echo green "OpenCode installed!"
    echo "  Configure your provider on first run"
    return 0
  else
    colour_echo yellow "OpenCode installation failed - you can install manually:"
    echo "  curl -fsSL https://opencode.ai/install | bash"
    return 1
  fi
}

# Install Codex CLI (OpenAI's coding assistant)
install_codex_cli() {
  colour_echo cyan "Installing Codex CLI..."

  if ! have npm; then
    colour_echo yellow "Node.js/npm not found. Please select 'Node.js' to install Codex CLI."
    return 1
  fi

  if install_npm_binary_to_local "@openai/codex" "codex" "Codex CLI"; then
    echo "  Set OPENAI_API_KEY from platform.openai.com"
    return 0
  else
    colour_echo yellow "Codex CLI installation failed"
    return 1
  fi
}
