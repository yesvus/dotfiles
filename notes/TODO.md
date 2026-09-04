# Arch setup TODO

Running notes for the Arch/niri box. Not applied automatically by chezmoi —
just tracked here so they don't get lost. Check items off as they're done.

## Terminal (default is now alacritty)

Switched default terminal from foot -> ghostty -> alacritty (2026-09-04).
Reason: ghostty's cold-start was ~450ms (~10x foot, ~4x alacritty,
benchmarked with `<term> -e true`, 10 runs) and its `gtk-single-instance`
speedup only kicks in for argument-less spawns (breaks as soon as any CLI
flag like `-e` is passed — confirmed by watching PIDs). alacritty has no
native split/tab system to fight with niri over either. ghostty is left
configured and installed for manual/occasional use only.

- [ ] `waybar/config.jsonc` still spawns `foot` directly for several widgets
      (system info/about, updates, btop floats x4, quick-claude floats x4).
      Decide whether to move these to `alacritty` for consistency — this is
      easier than the old ghostty plan since alacritty has a direct
      `--class=<name>` flag (ghostty has no equivalent), so the matching
      niri window rule for `arch-about-float` (currently keyed off foot's
      `--app-id`) can carry over with just `--class` instead.
- [ ] `zed/tasks.json` "Open in foot" task — same call: keep on foot or
      switch to alacritty.
- [ ] Decide whether `foot` stays installed as a fallback/lightweight
      terminal or gets fully retired once the above are migrated.
- [ ] `~/.config/ghostty/config` is still fully set up (theme, no tab
      bar, `gtk-single-instance` etc.) in case ghostty gets used manually
      again — nothing to do here, just noting it's intentionally kept.

## Dotfiles hygiene

- [ ] `~/.claude/CLAUDE.md` is a real file, but chezmoi's source wants it to
      be a symlink to `~/.config/ai-agents/GLOBAL.md`. That migration was
      started but never applied — GLOBAL.md still carries an Ubuntu/apt +
      Docker section that doesn't apply to this Arch/niri machine. Needs an
      Arch-flavored package policy section before the symlink is safe to
      apply here.
- [ ] `~/.config/niri/config.kdl.bak-*` and `config.bak` backup files are
      piling up in `~/.config/niri/` — not tracked in chezmoi (by design),
      but worth pruning periodically.
- [ ] `~/.config/niri/scripts/` only contains `__pycache__` right now (no
      tracked `.py` source) — figure out if the scripts were lost or just
      not committed anywhere, since niri config may reference them.
