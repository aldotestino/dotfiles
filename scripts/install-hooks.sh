#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR

if ! git -C "${DOTFILES_DIR}" rev-parse --git-dir >/dev/null 2>&1; then
  echo "${DOTFILES_DIR} is not a Git repository." >&2
  exit 1
fi

git -C "${DOTFILES_DIR}" config core.hooksPath .githooks
echo "Git hooks enabled from ${DOTFILES_DIR}/.githooks"
