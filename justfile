# Homebrew tap for miscellaneous tools

default:
	@just --list

# Audit a specific formula (from tap)
audit FORMULA:
	brew audit --strict --online {{FORMULA}}

# Audit all formulae (from tap)
audit-all:
	brew audit --strict --online

# Install a formula from the tap
install FORMULA:
	brew install temikus/tap/{{FORMULA}}

# Run a formula's test block (requires formula to be installed)
test FORMULA:
	brew test {{FORMULA}}

# Install, test, and uninstall in one go
check FORMULA:
	brew install temikus/tap/{{FORMULA}}
	brew test {{FORMULA}}
	brew uninstall {{FORMULA}}

# Local formula syntax/style check
style-check FORMULA:
	brew style ./Formula/{{FORMULA}}.rb

# Bump a formula to latest upstream release
bump FORMULA:
	./scripts/bump-formula.sh {{FORMULA}}

# Verify bump script reproduces current formula exactly
verify-bump FORMULA:
	./scripts/bump-formula.sh {{FORMULA}} --verify

# Lint the whole tap (formulae, workflows, shell scripts)
style:
	brew style .

# Generate README from formulae
generate-readme:
	./scripts/generate-readme.sh

# Full CI locally (requires tap to be installed)
ci:
	brew test-bot --only-cleanup-before
	brew test-bot --only-setup
	brew test-bot --only-tap-syntax
	brew test-bot --only-formulae