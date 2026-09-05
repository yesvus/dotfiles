#!/usr/bin/env bash
# Post-install bootstrap: run once inside a fresh Arch install (base system +
# bootloader already done manually). Installs AUR helper, base packages,
# restores dotfiles via chezmoi, enables services.
set -euo pipefail

DOTFILES_REPO="https://github.com/yesvus/dotfiles.git"

echo "==> Updating system"
sudo pacman -Syu --noconfirm

echo "==> Installing base packages"
sudo pacman -S --needed --noconfirm \
  base-devel git rust cargo chezmoi networkmanager \
  niri waybar foot greetd exfatprogs

echo "==> Enabling core services"
sudo systemctl enable --now NetworkManager
sudo systemctl enable greetd

echo "==> Installing yay (AUR helper)"
if ! command -v yay &>/dev/null; then
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
fi

echo "==> Restoring dotfiles with chezmoi"
chezmoi init --apply "$DOTFILES_REPO"

echo "==> Done. Review chezmoi diff/status, then reboot into your session."
