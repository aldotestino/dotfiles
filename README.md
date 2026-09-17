# Dotfiles

Reproducible macOS setup using Homebrew Bundle, GNU Stow, Oh My Zsh, Starship, nvm, and Gitleaks.

The repository manages:

- Command-line tools, applications, fonts, and VS Code extensions in `Brewfile`
- Portable shell, Git, GitHub CLI, editor, terminal, Herdr, Claude Code, and OpenCode configuration under `stow/`
- Global agent skills through the tracked `stow/agents/.agents/` snapshot
- Node.js, Bun, pnpm, OpenCode, Claude Code, Claude MCP servers, and `gh-stack` setup through `bootstrap.sh`

## Install on a new Mac

Run the hosted installer:

```bash
curl -fsSL https://dotfiles.aldotestino.dev/install.sh | bash
```

After bootstrap completes, enter `~/dotfiles` and run:

```bash
make stow-dry-run
make stow
make hooks
```

Bootstrap installs Apple's Command Line Tools and Homebrew when needed, installs `Brewfile`, and configures the remaining tools without linking dotfiles automatically.

The latest current Node.js release is installed by default. To use the latest LTS release instead:

```bash
NODE_VERSION='lts/*' ./bootstrap.sh
```

Avoid forced Homebrew Bundle cleanup during the initial migration; it may remove software not declared here.

## Validate

```bash
make brew-check
make check
make stow-dry-run
```

`make check` runs Gitleaks, Bash and Zsh syntax checks, ShellCheck, Brewfile validation, and an isolated Stow preview. The final command previews conflicts against the current home directory. None of these commands creates links or installs packages.

## Stow

Every immediate directory under `stow/` is discovered automatically.

```bash
make stow
make stow-dry-run
make stow-delete
```

Application packages link individual files so generated logs, caches, and sessions remain outside the repository. The `agents` package intentionally links the complete `~/.agents` directory; global skill updates may therefore modify this repository and should be reviewed before committing.

The Stow workflow never adopts existing files. Back up and compare an existing target file before resolving a conflict.

## Complete interactive setup

Authentication and machine identity are not tracked. Sign in to the services you use, including GitHub, npm, AWS, Google Cloud, Railway, gcx, Docker, Codex, Claude Code, and OpenCode.

Run `make herdr-integrations` after Claude Code, Codex, and OpenCode are available. Authenticate GitHub CLI and the other installed services interactively.

Linear may request OAuth authorization when its MCP server is first used. Private plugins, application licenses, Kubernetes credentials, and cloud profiles must be restored separately.

## Security and local overrides

Enable the repository-local pre-commit scan in every clone and run a full scan before pushing:

```bash
make hooks
make check-secrets
```

Keep secrets out of tracked files. Machine-specific shell and Git settings belong in:

```text
~/.zshrc.local
~/.gitconfig.local
```
