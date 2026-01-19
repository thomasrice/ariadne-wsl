#!/bin/bash

# Install Python tooling
install_python_tooling() {
  colour_echo cyan "Installing Python tools (uv + poetry)..."

  require_apt python3-pip
  add_or_replace_alias python "python3" "$BASHRC"

  # Install uv
  pip install uv

  # Install poetry
  pip install poetry

  echo "Python tooling installed: uv, poetry"
}
