#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "Gitleaks is required. Install it with: brew install gitleaks" >&2
  exit 1
fi

echo "Scanning current files..."
gitleaks dir --redact --verbose "${DOTFILES_DIR}"

if git -C "${DOTFILES_DIR}" rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "Scanning Git history..."
  gitleaks git --redact --verbose "${DOTFILES_DIR}"
else
  echo "No commits yet; skipping the history scan."
fi
