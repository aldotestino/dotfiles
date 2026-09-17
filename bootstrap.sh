#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR
readonly NODE_VERSION="${NODE_VERSION:-node}"

export PATH="${HOME}/.local/bin:${PATH}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap script currently supports macOS only." >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  cat >&2 <<'EOF'
Apple Command Line Tools are required.

Install them with:
  xcode-select --install

Then rerun this script.
EOF
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [[ ! -d "${HOME}/.oh-my-zsh/.git" ]]; then
  if [[ -e "${HOME}/.oh-my-zsh" ]]; then
    echo "Cannot install Oh My Zsh: ${HOME}/.oh-my-zsh already exists but is not a Git checkout." >&2
    exit 1
  fi

  echo "Installing Oh My Zsh..."
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh"
fi

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ ! -d "${NVM_DIR}/.git" ]]; then
  if [[ -e "${NVM_DIR}" ]]; then
    echo "Cannot install nvm: ${NVM_DIR} already exists but is not a Git checkout." >&2
    exit 1
  fi

  echo "Cloning nvm..."
  git clone https://github.com/nvm-sh/nvm.git "${NVM_DIR}"
fi

echo "Selecting the latest stable nvm release..."
git -C "${NVM_DIR}" fetch --tags --quiet origin
latest_nvm_version="$(git -C "${NVM_DIR}" tag --list 'v[0-9]*' --sort=-version:refname | sed -n '1p')"

if [[ -z "${latest_nvm_version}" ]]; then
  echo "Could not determine the latest nvm release." >&2
  exit 1
fi

git -C "${NVM_DIR}" checkout --quiet "${latest_nvm_version}"
echo "Using nvm ${latest_nvm_version}."

# shellcheck source=/dev/null
source "${NVM_DIR}/nvm.sh"

echo "Installing the latest Node.js release (${NODE_VERSION})..."
nvm install "${NODE_VERSION}"
nvm alias default "${NODE_VERSION}"

echo "Installing the latest Bun release with the official installer..."
curl -fsSL https://bun.com/install | bash

echo "Installing the latest pnpm release with the official installer..."
pnpm_shell_config="$(mktemp)"
trap 'rm -f "${pnpm_shell_config}"' EXIT
curl -fsSL https://get.pnpm.io/install.sh | env \
  PNPM_HOME="${HOME}/.pnpm" \
  ENV="${pnpm_shell_config}" \
  SHELL="$(command -v sh)" \
  sh -
rm -f "${pnpm_shell_config}"
trap - EXIT

echo "Installing the reviewed Brewfile..."
brew bundle --file="${DOTFILES_DIR}/Brewfile"

if [[ -f "${HOME}/.gitconfig" && ! -L "${HOME}/.gitconfig" ]]; then
  echo "Moving the generated ~/.gitconfig to ~/.gitconfig.local so stow can link the tracked one..."
  cat "${HOME}/.gitconfig" >>"${HOME}/.gitconfig.local"
  rm "${HOME}/.gitconfig"
fi

if ! gh extension list | grep -q '^gh stack[[:space:]]'; then
  echo "Installing the gh-stack extension..."
  gh extension install github/gh-stack
fi

if [[ ! -x "${HOME}/.local/bin/gs" ]]; then
  echo "Installing the gs alias for gh-stack..."
  gh stack alias
fi

echo "Installing the latest OpenCode release with the official V2 installer..."
curl -fsSL https://opencode.ai/v2/install | bash -s -- --no-modify-path

echo "Installing the latest Claude Code release with the official installer..."
curl -fsSL https://claude.ai/install.sh | bash

if ! claude mcp get linear >/dev/null 2>&1; then
  echo "Adding the Linear MCP server to Claude Code..."
  claude mcp add --scope user --transport http linear https://mcp.linear.app/mcp
fi

if ! claude mcp get railway >/dev/null 2>&1; then
  echo "Adding the Railway MCP server to Claude Code..."
  claude mcp add --scope user railway -- npx -y @railway/mcp-server
fi

cat <<EOF

Bootstrap complete.

Configuration has not been linked automatically. From ${DOTFILES_DIR}, review the dry run first:
  make stow-dry-run

Then create the links with:
  make stow

Finally enable the repository's Gitleaks hook:
  make hooks
EOF
