# shellcheck shell=bash
say "tenv"

# tenv manages Terraform, OpenTofu and Terragrunt versions. Its terraform and tofu
# commands pick each repo's version from .terraform-version, .opentofu-version or
# required_version.
if has tenv; then
  info "Already installed: $(command -v tenv)"
else
  brew_install tenv
fi

# Homebrew's own terraform or opentofu packages would fight tenv for those commands.
for tool in terraform tofu; do
  path="$(command -v "$tool" 2>/dev/null || true)"
  [[ -n "$path" && -L "$path" ]] || continue
  case "$(readlink "$path")" in
    *Cellar/tenv/*) ;;
    *) warn "$path isn't tenv's. Remove the other one (for example: brew uninstall $tool) so tenv's is used." ;;
  esac
done
