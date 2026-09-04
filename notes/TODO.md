# Arch setup TODO

Running notes for the Arch/niri box. Not applied automatically by chezmoi —
just tracked here so they don't get lost. Check items off as they're done.

## Terminal (ghostty migration)

- [ ] `waybar/config.jsonc` still spawns `foot` directly for several widgets
      (system info/about, updates, btop floats x4, quick-claude floats x4).
      Decide whether to move these to `ghostty` for consistency now that
      ghostty is the default terminal, and if so also check the matching
      niri window rule for `arch-about-float` (foot-specific app-id flag;
      ghostty's equivalent is the `class` config option / `--class=` — no
      direct `--app-id` flag).
- [ ] `zed/tasks.json` "Open in foot" task — same call: keep on foot or
      switch to ghostty.
- [ ] Decide whether `foot` stays installed as a fallback/lightweight
      terminal or gets fully retired once the above are migrated.

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
