# Ariadne WSL

**Your guide through the WSL labyrinth.**

Ariadne is a one-command bootstrap for setting up a modern development environment in Windows Subsystem for Linux (WSL). It installs and configures essential CLI tools with sensible defaults and beautiful themes.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/thomasrice/ariadne-wsl/main/bootstrap.sh | bash
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

## Documentation

Full documentation: [thomasrice.com/ariadne](https://thomasrice.com/ariadne)

## License

MIT License - see [LICENSE](LICENSE)
