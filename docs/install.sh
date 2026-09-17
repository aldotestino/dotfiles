#!/usr/bin/env bash

set -euo pipefail

readonly REPOSITORY="https://github.com/aldotestino/dotfiles.git"
readonly DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer supports macOS only." >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Apple Command Line Tools are required.

Install them with:
  xcode-select --install

Then rerun this installer.
EOF
  exit 1
fi

if [[ -e "${DOTFILES_DIR}" ]]; then
  echo "${DOTFILES_DIR} already exists; refusing to overwrite it." >&2
  exit 1
fi

git clone --depth=1 "${REPOSITORY}" "${DOTFILES_DIR}"
exec "${DOTFILES_DIR}/bootstrap.sh"
