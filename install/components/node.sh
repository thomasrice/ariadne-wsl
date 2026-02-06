#!/bin/bash

# Install Node.js tooling
install_node_tooling() {
  colour_echo cyan "Installing Node.js 20 LTS..."

  local min_version="20.0.0"

  if command -v node >/dev/null 2>&1; then
    local current
    current="$(node -v | sed 's/^v//')"
    if [ "$(printf '%s\n' "$min_version" "$current" | sort -V | tail -n1)" = "$current" ]; then
      echo "Node.js $current already installed."
      return
    fi
  fi

  require_apt curl
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  require_apt nodejs

  echo "Node.js $(node -v) installed."
}
