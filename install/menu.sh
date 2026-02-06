#!/bin/bash

# Checkbox menu for selecting tools to install
# Uses whiptail if available, otherwise falls back to dialog

# Tool definitions: ID|Label|Description|Default (ON/OFF)
TOOLS=(
  "starship|Starship|Modern shell prompt with themes|ON"
  "zoxide|zoxide|Smart cd that learns your habits|ON"
  "eza|eza|Modern ls with icons and git info|ON"
  "bat|bat|Cat with syntax highlighting|ON"
  "ripgrep|ripgrep|Fast recursive text search (rg)|ON"
  "fd|fd|Fast file finder|ON"
  "fzf|fzf|Fuzzy finder for files & history|ON"
  "neovim|neovim|Modern vim editor|ON"
  "lazygit|LazyGit|Terminal UI for git|ON"
  "python|Python tools|uv + poetry for Python dev|OFF"
  "node|Node.js|Node.js 20 LTS (needed for AI tools)|OFF"
  "claude-code|Claude Code|Anthropic's AI coding assistant|OFF"
  "opencode|OpenCode|Open-source AI coding tool|OFF"
  "codex|Codex CLI|OpenAI's coding assistant|OFF"
)

# Parse tool definition into variables
parse_tool() {
  local def="$1"
  IFS='|' read -r TOOL_ID TOOL_LABEL TOOL_DESC TOOL_DEFAULT <<< "$def"
}

# Detect available dialog tool
get_dialog_cmd() {
  if command -v whiptail >/dev/null 2>&1; then
    echo "whiptail"
  elif command -v dialog >/dev/null 2>&1; then
    echo "dialog"
  else
    echo ""
  fi
}

# Show checkbox menu and return selected tools
show_menu() {
  local dialog_cmd
  dialog_cmd="$(get_dialog_cmd)"

  if [ -z "$dialog_cmd" ]; then
    # No dialog tool available, use simple text menu
    show_text_menu
    return
  fi

  # Build checklist arguments
  local args=()
  for tool_def in "${TOOLS[@]}"; do
    parse_tool "$tool_def"
    args+=("$TOOL_ID" "$TOOL_DESC" "$TOOL_DEFAULT")
  done

  local height=20
  local width=70
  local list_height=${#TOOLS[@]}

  local result
  result=$("$dialog_cmd" --title "Ariadne - Select Tools" \
    --checklist "Use SPACE to toggle, ENTER to confirm:" \
    $height $width $list_height \
    "${args[@]}" \
    3>&1 1>&2 2>&3)

  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo "CANCELLED"
    return 1
  fi

  # Clean up result (remove quotes)
  result=$(echo "$result" | tr -d '"')
  echo "$result"
}

# Fallback text menu when no dialog tool is available
show_text_menu() {
  echo
  colour_echo cyan "Ariadne - Select Tools to Install"
  echo "=================================="
  echo

  # Initialize selection array with defaults
  declare -A selections
  for tool_def in "${TOOLS[@]}"; do
    parse_tool "$tool_def"
    if [ "$TOOL_DEFAULT" = "ON" ]; then
      selections[$TOOL_ID]=1
    else
      selections[$TOOL_ID]=0
    fi
  done

  while true; do
    # Display current selections
    local i=1
    for tool_def in "${TOOLS[@]}"; do
      parse_tool "$tool_def"
      local mark=" "
      if [ "${selections[$TOOL_ID]}" = "1" ]; then
        mark="x"
      fi
      printf "  %2d. [%s] %-15s %s\n" "$i" "$mark" "$TOOL_LABEL" "$TOOL_DESC"
      ((i++))
    done

    echo
    echo "Enter number to toggle, 'a' for all, 'n' for none, or ENTER to continue:"
    read -r choice

    case "$choice" in
      "")
        break
        ;;
      a|A)
        for tool_def in "${TOOLS[@]}"; do
          parse_tool "$tool_def"
          selections[$TOOL_ID]=1
        done
        ;;
      n|N)
        for tool_def in "${TOOLS[@]}"; do
          parse_tool "$tool_def"
          selections[$TOOL_ID]=0
        done
        ;;
      [0-9]*)
        if [ "$choice" -ge 1 ] && [ "$choice" -le ${#TOOLS[@]} ]; then
          local idx=$((choice - 1))
          parse_tool "${TOOLS[$idx]}"
          if [ "${selections[$TOOL_ID]}" = "1" ]; then
            selections[$TOOL_ID]=0
          else
            selections[$TOOL_ID]=1
          fi
        fi
        ;;
    esac
    echo
  done

  # Build result string
  local result=""
  for tool_def in "${TOOLS[@]}"; do
    parse_tool "$tool_def"
    if [ "${selections[$TOOL_ID]}" = "1" ]; then
      result="$result $TOOL_ID"
    fi
  done

  echo "$result"
}

# Check if a tool was selected
is_selected() {
  local tool="$1"
  local selected="$2"
  [[ " $selected " == *" $tool "* ]]
}
