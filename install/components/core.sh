#!/bin/bash

# Install core packages that are always required
install_core_packages() {
  colour_echo cyan "Installing core packages..."
  require_apt sudo ca-certificates curl git unzip bash-completion libfuse2
}
