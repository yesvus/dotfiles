# ~/.config/shell/onedark-term.sh
#
# Push the One Dark palette onto whatever terminal is attached to this shell,
# including terminals on *other* machines that SSH in here.
#
# What this can and cannot do:
#
#   COLORS  -> forceable. Terminals accept OSC 4/10/11/12 escape sequences that
#              rewrite the live palette for the duration of the session. This
#              travels over SSH because it is just bytes on stdout, so a remote
#              client keeps its own theme everywhere else but renders One Dark
#              while attached to this host.
#
#   FONT    -> NOT forceable in general. The font is chosen by the client-side
#              terminal emulator before any byte arrives; there is no in-band
#              protocol for it in Alacritty, foot, Ghostty, kitty, WezTerm,
#              Windows Terminal or iTerm2. The only exceptions are xterm and
#              rxvt-unicode, which implement OSC 50 font selection; those are
#              handled below. Everywhere else the font has to be installed and
#              configured on the client (see `onedark_font_hint`).
#
# Escape hatch: export ONEDARK_NO_OSC=1 to disable.

# True when the terminal ultimately rendering this session cannot handle OSC
# palette control: the bare Linux console and fbterm use private protocols
# (OSC P / fbterm escapes) handled separately in .bashrc.
#
# Inside tmux, $TERM describes tmux's *emulation* (tmux-256color), not the real
# client, so a naive $TERM check would happily push OSC 4 through passthrough
# onto a Linux console and paint garbage on screen. Ask tmux what the attached
# client actually is.
onedark_term_unsupported() {
	[ -n "$FBTERM" ] && return 0
	case "$TERM" in
	linux | fbterm | dumb | "") return 0 ;;
	esac

	if [ -n "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
		local client
		client=$(tmux display-message -p '#{client_termname}' 2>/dev/null)
		case "$client" in
		linux | fbterm | dumb) return 0 ;;
		esac
	fi
	return 1
}

onedark_apply_palette() {
	[ -n "$ONEDARK_NO_OSC" ] && return 0
	case $- in *i*) ;; *) return 0 ;; esac
	[ -t 1 ] || return 0
	onedark_term_unsupported && return 0

	# Inside tmux, OSC must be wrapped in a DCS passthrough envelope and tmux
	# must have `set -g allow-passthrough on` (see .tmux.conf). Inner ESC
	# bytes are doubled per the tmux passthrough grammar.
	local pre='' post='' esc
	esc=$(printf '\033')
	if [ -n "$TMUX" ]; then
		pre="${esc}Ptmux;${esc}"
		post="${esc}\\"
	fi

	local seq=''
	_onedark_osc() {
		# $1 = OSC body, e.g. "11;#282c34"
		local body="$1"
		if [ -n "$TMUX" ]; then
			# double every ESC inside the payload
			seq="${seq}${pre}${esc}]${body}${esc}${esc}\\${post}"
		else
			seq="${seq}${esc}]${body}${esc}\\"
		fi
	}

	# 16-color palette
	_onedark_osc '4;0;#282c34'
	_onedark_osc '4;1;#e06c75'
	_onedark_osc '4;2;#98c379'
	_onedark_osc '4;3;#e5c07b'
	_onedark_osc '4;4;#61afef'
	_onedark_osc '4;5;#c678dd'
	_onedark_osc '4;6;#56b6c2'
	_onedark_osc '4;7;#abb2bf'
	_onedark_osc '4;8;#545862'
	_onedark_osc '4;9;#e06c75'
	_onedark_osc '4;10;#98c379'
	_onedark_osc '4;11;#e5c07b'
	_onedark_osc '4;12;#61afef'
	_onedark_osc '4;13;#c678dd'
	_onedark_osc '4;14;#56b6c2'
	_onedark_osc '4;15;#ffffff'

	# foreground / background / cursor
	_onedark_osc '10;#abb2bf'
	_onedark_osc '11;#282c34'
	_onedark_osc '12;#61afef'

	printf '%s' "$seq"
	unset -f _onedark_osc

	# Blinking bar cursor (DECSCUSR 5), matching the local terminal configs.
	printf '\033[5 q'
}

# Hand the client's own colors back. Without this, a remote user who SSHes in
# and then exits is left staring at One Dark in what should be their own theme,
# because OSC palette changes persist in the emulator after the session ends.
onedark_reset_palette() {
	[ -n "$ONEDARK_NO_OSC" ] && return 0
	[ -t 1 ] || return 0
	onedark_term_unsupported && return 0
	# OSC 104 = reset palette, 110/111/112 = reset fg/bg/cursor to the
	# client's own configured defaults.
	if [ -n "$TMUX" ]; then
		printf '\033Ptmux;\033\033]104\033\033\\\033\\'
		printf '\033Ptmux;\033\033]110\033\033\\\033\\'
		printf '\033Ptmux;\033\033]111\033\033\\\033\\'
		printf '\033Ptmux;\033\033]112\033\033\\\033\\'
	else
		printf '\033]104\033\\\033]110\033\\\033]111\033\\\033]112\033\\'
	fi
}

# OSC 50 font selection. Only xterm and rxvt-unicode implement this, and only
# xterm built with Xft accepts a fontconfig pattern. Harmless no-op elsewhere,
# but gated anyway so we never emit junk to terminals that would print it.
onedark_apply_font() {
	[ -n "$ONEDARK_NO_OSC" ] && return 0
	[ -t 1 ] || return 0
	onedark_term_unsupported && return 0
	[ -n "$TMUX" ] && return 0 # tmux owns the font decision; passthrough is unreliable here
	font="${ONEDARK_FONT:-JetBrainsMono Nerd Font Mono}"
	size="${ONEDARK_FONT_SIZE:-11}"
	case "$TERM" in
	rxvt-unicode* | rxvt*)
		printf '\033]50;xft:%s:size=%s\007' "$font" "$size"
		;;
	xterm*)
		# Opt-in: plain xterm without Xft will beep or ignore this.
		[ -n "$ONEDARK_XTERM_FONT" ] && printf '\033]50;%s:size=%s\007' "$font" "$size"
		;;
	esac
}

# Tell a connecting user what to install if their client is missing the font.
# Nerd Font glyphs cannot be detected in-band reliably, so this is advisory and
# only fires for interactive SSH logins, once, and only when asked for.
onedark_font_hint() {
	cat <<'EOF'
This host renders best with a Nerd Font on the *client* side.
The font cannot be pushed over SSH; install it on your own machine:

  Arch      sudo pacman -S ttf-jetbrains-mono-nerd
  Debian    sudo apt install fonts-jetbrains-mono   # then add Nerd Font patch
  macOS     brew install --cask font-jetbrains-mono-nerd-font
  manual    https://github.com/ryanoasis/nerd-fonts/releases  (JetBrainsMono.zip)

Then point your terminal at "JetBrainsMono Nerd Font Mono".
Colors are already forced to One Dark automatically.
EOF
}

# Called from the tmux `client-attached` hook, which runs with no controlling
# terminal, so the usual `[ -t 1 ]` path cannot work. Instead we ask tmux for the
# attached client's tty and write straight to it. Going direct to the client tty
# also means no DCS passthrough wrapper is needed: those bytes never traverse
# tmux's parser. OSC 4/10/11/12 do not move the cursor, so writing behind tmux's
# back cannot corrupt its screen model.
onedark_tmux_client_repaint() {
	[ -n "$ONEDARK_NO_OSC" ] && return 0
	command -v tmux >/dev/null 2>&1 || return 0

	tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null) || return 0
	[ -n "$tty" ] && [ -w "$tty" ] || return 0

	termname=$(tmux display-message -p '#{client_termname}' 2>/dev/null)
	case "$termname" in
	linux | fbterm | dumb | "") return 0 ;;
	esac

	{
		printf '\033]4;0;#282c34\033\\\033]4;1;#e06c75\033\\\033]4;2;#98c379\033\\\033]4;3;#e5c07b\033\\'
		printf '\033]4;4;#61afef\033\\\033]4;5;#c678dd\033\\\033]4;6;#56b6c2\033\\\033]4;7;#abb2bf\033\\'
		printf '\033]4;8;#545862\033\\\033]4;9;#e06c75\033\\\033]4;10;#98c379\033\\\033]4;11;#e5c07b\033\\'
		printf '\033]4;12;#61afef\033\\\033]4;13;#c678dd\033\\\033]4;14;#56b6c2\033\\\033]4;15;#ffffff\033\\'
		printf '\033]10;#abb2bf\033\\\033]11;#282c34\033\\\033]12;#61afef\033\\'
	} >"$tty" 2>/dev/null
}

# Sourcing this file normally applies the theme immediately. Logout hooks want
# the functions without the side effect, so they set ONEDARK_LIB_ONLY=1 and then
# call onedark_reset_palette themselves.
if [ -z "$ONEDARK_LIB_ONLY" ]; then
	onedark_apply_palette
	onedark_apply_font
fi
