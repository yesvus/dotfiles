# Dotfiles

Personal configuration managed with [chezmoi](https://www.chezmoi.io/).

## Bootstrap

Install chezmoi, then initialize and apply this repository:

```sh
chezmoi init --apply <repository-url>
```

## Daily use

```sh
chezmoi diff
chezmoi add ~/.zshrc
chezmoi cd
git status
```

Global AI-agent rules live in `~/.config/ai-agents/GLOBAL.md`. Tool-specific
instruction files are symlinks to that canonical file.
