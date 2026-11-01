# shellcheck shell=bash
say "tenv config"

# Install a repo's pinned Terraform or OpenTofu version the first time it's needed.
write_rc_block 'export TENV_AUTO_INSTALL=true' tenv
