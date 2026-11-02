# shellcheck shell=bash
say "bat config"

# The "ansi" theme uses the terminal's colors, so highlighting follows the WezTerm theme.
# cat becomes bat in interactive shells; scripts and pipes still get plain output.
write_rc_block "export BAT_THEME=ansi
command -v bat >/dev/null && alias cat='bat --paging=never'" bat
