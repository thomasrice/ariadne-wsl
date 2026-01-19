#!/bin/bash

# Configure global Git identity, prompting only when needed
configure_git_identity() {
  local existing_name existing_email name email

  existing_name="$(git config --global user.name 2>/dev/null || true)"
  existing_email="$(git config --global user.email 2>/dev/null || true)"

  if [ -n "$existing_name" ]; then
    name="$existing_name"
    echo "Using existing Git name: $name"
  else
    read -rp "Git full name (for commits): " name
  fi

  if [ -n "$existing_email" ]; then
    email="$existing_email"
    echo "Using existing Git email: $email"
  else
    read -rp "Git email address: " email
  fi

  git config --global user.name "$name"
  git config --global user.email "$email"

  echo
  echo "Git user: $name <$email>"
  echo
}
