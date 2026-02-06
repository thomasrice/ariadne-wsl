#!/bin/bash

# Install Claude Code (Anthropic's AI coding assistant)
install_claude_code() {
  colour_echo cyan "Installing Claude Code..."

  if ! have npm; then
    colour_echo yellow "Node.js/npm not found. Please select 'Node.js' to install Claude Code."
    return 1
  fi

  if npm install -g @anthropic-ai/claude-code; then
    colour_echo green "Claude Code installed!"
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

  if npm install -g @openai/codex; then
    colour_echo green "Codex CLI installed!"
    echo "  Set OPENAI_API_KEY from platform.openai.com"
    return 0
  else
    colour_echo yellow "Codex CLI installation failed"
    return 1
  fi
}
