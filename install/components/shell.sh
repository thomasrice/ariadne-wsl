#!/bin/bash

# Starship prompt installer (official script wrapper)
install_starship() {
  colour_echo cyan "Installing Starship prompt..."
  # Suppress the "follow these steps" output - we handle bashrc setup ourselves
  curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
  if command -v starship >/dev/null 2>&1; then
    colour_echo green "Starship installed!"
  else
    colour_echo yellow "Starship installation may have failed"
    return 1
  fi
}

# Copy bundled Starship configuration
sync_starship_config() {
  local src="$ARI_ASSETS/starship/starship.toml"
  local dest_dir="$HOME/.config"
  local dest="$dest_dir/starship.toml"
  local themes_src="$ARI_ASSETS/starship/themes"
  local themes_dest="$ARI_PATH/starship-themes"
  local default_theme="ocean-wave"

  if [ ! -f "$src" ]; then
    echo "Warning: Starship config not found at $src"
    return
  fi

  mkdir -p "$dest_dir"
  install -m 0644 "$src" "$dest"

  if [ -d "$themes_src" ]; then
    rm -rf "$themes_dest"
    mkdir -p "$themes_dest"
    cp -a "$themes_src"/. "$themes_dest/"
    echo "$default_theme" > "$themes_dest/.current"
  fi
}

# Install eza (modern ls)
install_eza() {
  colour_echo cyan "Installing eza..."
  wget -qO eza.tar.gz https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz
  sudo tar xf eza.tar.gz --strip-components=1 -C /usr/local/bin
  rm -rf eza.tar.gz
}

# Copy bundled eza theme
sync_eza_theme() {
  local src_dir="$ARI_ASSETS/eza"
  local dest_dir="$HOME/.config/eza"
  local src_file="$src_dir/theme.yml"

  if [ ! -f "$src_file" ]; then
    return
  fi

  mkdir -p "$dest_dir"
  install -m 0644 "$src_file" "$dest_dir/theme.yml"
}

# Install zoxide (smart cd)
install_zoxide() {
  colour_echo cyan "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

# Ensure splash screen shows on new terminal
ensure_ari_splash() {
  sed -i '/## ARI: SPLASH START/,/## ARI: SPLASH END/d' "$BASHRC" 2>/dev/null || true
  sed -i '/command -v ari-splash/d' "$BASHRC" 2>/dev/null || true

  local splash_cmd='case $- in *i*) [ -z "$ARI_SPLASH_SHOWN" ] && ARI_SPLASH_SHOWN=1 && command -v ari-splash >/dev/null 2>&1 && ari-splash ;; esac'
  append_once "$splash_cmd" "$BASHRC"
}

# Apply all shell customisations
setup_shell_environment() {
  local selected="$1"

  # Ensure ~/bin and ~/.local/bin exist and are part of PATH
  for d in "$HOME/bin" "$HOME/.local/bin"; do
    [ -d "$d" ] || mkdir -p "$d"
    case ":$PATH:" in
      *":$d:"*) ;;
      *) export PATH="$d:$PATH" ;;
    esac
  done

  if ! grep -q '## ARI: PATH local bins' "$BASHRC"; then
    cat >> "$BASHRC" <<'EOF'

## ARI: PATH local bins
for d in "$HOME/bin" "$HOME/.local/bin"; do
  [ -d "$d" ] || mkdir -p "$d"
  case ":$PATH:" in
    *":$d:"*) ;;
    *) export PATH="$d:$PATH" ;;
  esac
done
## END ARI
EOF
  fi

  # Starship
  if is_selected "starship" "$selected"; then
    install_starship
    sync_starship_config
    append_once 'eval "$(starship init bash)"' "$BASHRC"
  fi

  # zoxide
  if is_selected "zoxide" "$selected"; then
    install_zoxide
    append_once 'eval "$(zoxide init bash --cmd cd)"' "$BASHRC"
  fi

  # eza
  if is_selected "eza" "$selected"; then
    install_eza || true
    if have eza; then
      local eza_cmd="eza"

      add_or_replace_alias ls  "$eza_cmd -lh --icons --group-directories-first --no-quotes --no-permissions --no-user --git 2>/dev/null" "$BASHRC"
      add_or_replace_alias la  "$eza_cmd -lah --icons --group-directories-first --no-quotes --git 2>/dev/null" "$BASHRC"
      add_or_replace_alias ll  "$eza_cmd -lh --icons --group-directories-first --no-quotes --git 2>/dev/null" "$BASHRC"

      if ! grep -q 'EZA_CONFIG_DIR=' "$BASHRC"; then
        cat <<'EOF' >> "$BASHRC"

# --- eza theme configuration ---
unset EZA_COLORS
unset LS_COLORS
export EZA_CONFIG_DIR="$HOME/.config/eza"
# --- end eza theme configuration ---
EOF
      fi

      sync_eza_theme
    fi
  fi

  # Common aliases
  add_or_replace_alias n "nvim" "$BASHRC"
  add_or_replace_alias exp "explorer.exe ." "$BASHRC"
  add_or_replace_alias open "explorer.exe" "$BASHRC"

  append_once 'export LESS="-R"' "$BASHRC"

  # Bash completion
  if ! grep -q 'bash_completion' "$BASHRC"; then
    cat <<'EOF' >> "$BASHRC"

# Enable bash completion (Debian/Ubuntu path)
if [ -f /usr/share/bash-completion/bash_completion ] && ! shopt -oq posix; then
  . /usr/share/bash-completion/bash_completion
fi
EOF
  fi
}

# Install Ariadne bin scripts
install_ari_bin_scripts() {
  local src_dir="$ARI_ASSETS/bin"
  local dest_dir="$ARI_PATH/bin"

  if [ ! -d "$src_dir" ]; then
    return
  fi

  mkdir -p "$dest_dir"
  cp -a "$src_dir/." "$dest_dir/"

  if [ -d "$dest_dir" ]; then
    chmod +x "$dest_dir"/* >/dev/null 2>&1 || true
  fi

  append_once "export PATH='$dest_dir':\$PATH" "$BASHRC"
}
