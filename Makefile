STOW_TARGET ?= $(HOME)

.PHONY: brew-check brew-validate check check-secrets help herdr-integrations hooks shellcheck stow stow-check stow-delete stow-dry-run syntax

help:
	@echo "brew-check     Check Brewfile dependencies without installing"
	@echo "brew-validate  Validate the Brewfile without installing"
	@echo "check          Run all local repository checks"
	@echo "check-secrets  Scan current files and Git history"
	@echo "herdr-integrations  Install Claude, Codex, and OpenCode integrations"
	@echo "hooks          Enable tracked Git hooks"
	@echo "shellcheck     Analyze tracked shell scripts"
	@echo "stow           Link configuration into HOME"
	@echo "stow-check     Preview Stow links in an isolated temporary home"
	@echo "stow-delete    Remove configuration links"
	@echo "stow-dry-run   Preview Stow links"
	@echo "syntax         Check Bash and Zsh syntax"
brew-check:
	brew bundle check --file=./Brewfile

brew-validate:
	brew bundle list --file=./Brewfile >/dev/null

check: check-secrets syntax shellcheck brew-validate stow-check

syntax:
	bash -n bootstrap.sh scripts/*.sh .githooks/pre-commit
	zsh -n stow/zsh/.zshrc stow/zsh/.zprofile

shellcheck:
	shellcheck bootstrap.sh scripts/*.sh .githooks/pre-commit

check-secrets:
	./scripts/check-secrets.sh

hooks:
	./scripts/install-hooks.sh

herdr-integrations:
	herdr integration install claude
	herdr integration install codex
	herdr integration install opencode

stow:
	./scripts/stow.sh

stow-delete:
	./scripts/stow.sh --delete

stow-check:
	@target="$$(mktemp -d)"; \
	trap 'rmdir "$$target"' EXIT; \
	HOME="$$target" ./scripts/stow.sh --dry-run

stow-dry-run:
	HOME="$(STOW_TARGET)" ./scripts/stow.sh --dry-run
