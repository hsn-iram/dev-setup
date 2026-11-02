# shellcheck shell=bash
say "Claude Code config"

# ~/.local/bin holds the native claude binary and the tclaude helper.
# shellcheck disable=SC2016  # literal $HOME/$PATH wanted in the rc file
write_rc_block 'export PATH="$HOME/.local/bin:$PATH"'
