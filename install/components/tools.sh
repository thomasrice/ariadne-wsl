#!/bin/bash

# Install bat (cat with syntax highlighting)
setup_bat() {
  colour_echo cyan "Installing bat..."
  require_apt bat

  local assets_dir="$ARI_ASSETS/bat"
  local config_dir="$HOME/.config/bat"

  mkdir -p "$config_dir"

  if [ -f "$assets_dir/config" ]; then
    install -m 0644 "$assets_dir/config" "$config_dir/config"
  fi

  # Build cache if batcat is available
  if command -v batcat >/dev/null 2>&1; then
    batcat cache --build >/dev/null 2>&1 || true
    # Alias cat to batcat (with plain style for piping)
    add_or_replace_alias cat "batcat --paging=never" "$BASHRC"
  fi

  # Create more function using bat
  setup_more_function
}

setup_more_function() {
  remove_alias more "$BASHRC"
  sed -i '/# ARI: MORE FUNCTION START/,/# ARI: MORE FUNCTION END/d' "$BASHRC"
  cat <<'EOF' >> "$BASHRC"
# ARI: MORE FUNCTION START
more() {
  if command -v batcat >/dev/null 2>&1; then
    batcat "$@"
  else
    command more "$@"
  fi
}
# ARI: MORE FUNCTION END
EOF
}

# Install ripgrep
install_ripgrep() {
  colour_echo cyan "Installing ripgrep..."
  require_apt ripgrep
}

# Install fd (fast file finder)
install_fd() {
  colour_echo cyan "Installing fd..."
  require_apt fd-find

  # Create fd alias for fdfind
  add_or_replace_alias fd "fdfind" "$BASHRC"
}

# Install fzf (fuzzy finder)
install_fzf() {
  colour_echo cyan "Installing fzf..."
  require_apt fzf

  add_or_replace_alias ff "fzf" "$BASHRC"

  # Add nf function: fuzzy find then open in nvim
  remove_alias nf "$BASHRC"
  append_once 'nf(){ local file; file="$(fzf)"; [ -n "$file" ] && nvim "$file"; }' "$BASHRC"
}

# Install neovim
install_neovim() {
  colour_echo cyan "Installing neovim..."
  require_apt neovim
}

# Install LazyGit
_lg_detect() {
  local m
  m="$(uname -m)"
  case "$m" in
    x86_64|amd64)   echo "x86_64" ;;
    i386|i486|i586|i686) echo "32-bit" ;;
    aarch64|arm64)  echo "arm64" ;;
    armv7l)         echo "armv7" ;;
    armv6l)         echo "armv6" ;;
    *)
      if command -v dpkg >/dev/null 2>&1; then
        case "$(dpkg --print-architecture)" in
          amd64) echo "x86_64" ;;
          i386)  echo "32-bit" ;;
          arm64) echo "arm64" ;;
          armhf) echo "armv7" ;;
          armel) echo "armv6" ;;
          *)     echo "unknown" ;;
        esac
      else
        echo "unknown"
      fi
      ;;
  esac
}

_lg_candidate_assets() {
  case "$1" in
    x86_64)  echo "Linux_x86_64 linux_amd64" ;;
    32-bit)  echo "Linux_32-bit linux_32-bit" ;;
    arm64)   echo "Linux_arm64 linux_arm64" ;;
    armv7)   echo "Linux_armv7 linux_armv7 Linux_armv6 linux_armv6" ;;
    armv6)   echo "Linux_armv6 linux_armv6" ;;
    *)       echo "" ;;
  esac
}

install_lazygit() {
  colour_echo cyan "Installing LazyGit..."
  local version="${1:-0.55.1}"
  local base="https://github.com/jesseduffield/lazygit/releases/download/v${version}"
  local arch
  arch="$(_lg_detect)"
  if [ "$arch" = "unknown" ]; then
    echo "Unable to detect architecture. Skipping LazyGit." >&2
    return 1
  fi

  local candidates
  IFS=' ' read -r -a candidates <<<"$(_lg_candidate_assets "$arch")"
  if [ ${#candidates[@]} -eq 0 ]; then
    echo "No candidate assets for arch '$arch'." >&2
    return 1
  fi

  local url=""
  local suf test_url
  for suf in "${candidates[@]}"; do
    test_url="${base}/lazygit_${version}_${suf}.tar.gz"
    if curl -fsI "$test_url" >/dev/null 2>&1; then
      url="$test_url"
      break
    fi
  done

  if [ -z "$url" ]; then
    echo "Could not find LazyGit for arch '$arch'." >&2
    return 1
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' RETURN

  curl -fsSL "$url" -o "$tmpdir/lazygit.tgz"
  tar -xzf "$tmpdir/lazygit.tgz" -C "$tmpdir"

  if [ ! -f "$tmpdir/lazygit" ]; then
    echo "Archive did not contain lazygit binary." >&2
    return 1
  fi

  sudo install -m 0755 "$tmpdir/lazygit" /usr/local/bin/lazygit
  echo "Installed: $(/usr/local/bin/lazygit --version 2>/dev/null || echo lazygit)"

  add_or_replace_alias lg "lazygit" "$BASHRC"
}
