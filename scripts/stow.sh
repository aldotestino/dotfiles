#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DOTFILES_DIR
readonly STOW_DIR="${DOTFILES_DIR}/stow"

PACKAGES=()
FOLDING_PACKAGES=()
NO_FOLDING_PACKAGES=()
for package_dir in "${STOW_DIR}"/*/; do
  [[ -d "${package_dir}" ]] || continue
  package_name="${package_dir%/}"
  package_name="${package_name##*/}"
  PACKAGES+=("${package_name}")

  if [[ "${package_name}" == "agents" ]]; then
    FOLDING_PACKAGES+=("${package_name}")
  else
    NO_FOLDING_PACKAGES+=("${package_name}")
  fi
done

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  echo "No Stow packages found in ${STOW_DIR}." >&2
  exit 1
fi

readonly PACKAGES
readonly FOLDING_PACKAGES
readonly NO_FOLDING_PACKAGES
args=(--dir="${STOW_DIR}" --target="${HOME}")

if [[ "${1:-}" == "--dry-run" ]]; then
  args+=(--restow --simulate --verbose=2)
elif [[ "${1:-}" == "--delete" ]]; then
  args+=(--delete)
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--dry-run|--delete]" >&2
  exit 2
else
  args+=(--restow)
fi

if [[ ${#NO_FOLDING_PACKAGES[@]} -gt 0 ]]; then
  stow "${args[@]}" --no-folding "${NO_FOLDING_PACKAGES[@]}"
fi

if [[ ${#FOLDING_PACKAGES[@]} -gt 0 ]]; then
  stow "${args[@]}" "${FOLDING_PACKAGES[@]}"
fi
