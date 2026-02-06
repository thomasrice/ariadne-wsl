# Ariadne WSL

**Your guide through the WSL labyrinth.**

Ariadne is a one-command bootstrap for setting up a modern development environment in Windows Subsystem for Linux (WSL). It installs and configures essential CLI tools with sensible defaults and beautiful themes.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/thomasrice/ariadne-wsl/master/bootstrap.sh | bash
```

## What's Installed

Ariadne presents a checkbox menu letting you choose which tools to install:

| Tool | Description | Default |
|------|-------------|---------|
| **Starship** | Modern, fast shell prompt with themes | ✓ |
| **zoxide** | Smart `cd` that learns your habits | ✓ |
| **eza** | Modern `ls` with icons and git info | ✓ |
| **bat** | `cat` with syntax highlighting | ✓ |
| **ripgrep** | Fast recursive text search (`rg`) | ✓ |
| **fd** | Fast file finder | ✓ |
| **fzf** | Fuzzy finder for files & history | ✓ |
| **neovim** | Modern vim editor | ✓ |
| **LazyGit** | Terminal UI for git | ✓ |
| **Python tools** | uv + poetry for Python dev | Optional |
| **Node.js** | Node.js 20 LTS | Optional |

## Requirements

- Windows 10/11 with WSL2
- Ubuntu 22.04 or later (recommended)
- A [Nerd Font](https://www.nerdfonts.com/) for icons

## Security Note

Ariadne installs a number of third-party tools from official upstream sources
(apt repositories, GitHub releases, and vendor install scripts). Review
`install/components/*.sh` if you want to audit exactly what runs on your
machine before installation.

## Themes

Change your prompt colours with:

```bash
ari-theme          # List available themes
ari-theme ocean-wave  # Apply a theme
```

Available themes:
- Ocean Wave (default)
- Forest Glade
- Sunset Blaze
- Midnight Aurora
- Rose Garden
- Arctic Frost

## Commands

After installation, these shortcuts are available:

| Command | Description |
|---------|-------------|
| `ls` / `ll` / `la` | List files with icons |
| `cd <path>` | Smart navigation (zoxide) |
| `rg <pattern>` | Fast text search |
| `fd <pattern>` | Fast file finder |
| `ff` | Fuzzy file finder |
| `nf` | Fuzzy find then open in neovim |
| `lg` | LazyGit |
| `more <file>` | View with syntax highlighting |
| `ari-theme` | Change prompt theme |
| `shortcuts` | Show available shortcuts |

## Troubleshooting

- If the installer is run via `curl | bash`, it reconnects to your terminal so
  interactive prompts still work.
- If command aliases are not visible right away, close and reopen your terminal.
- AI tools (`claude-code`, `codex`) require Node.js and Ariadne will add Node.js
  automatically when those are selected.

## Documentation

Full documentation: [www.ariadne-wsl.com](https://www.ariadne-wsl.com)

## License

MIT License - see [LICENSE](LICENSE)
