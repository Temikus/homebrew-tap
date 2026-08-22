# Homebrew tap for miscellaneous tools

default:
	@just --list

# Audit a specific formula (or all if no argument)
audit FORMULA='':
	brew audit --strict --online {{if FORMULA != ''}}--formula ./Formula/{{FORMULA}}.rb{{else}}{{end}}

# Install a formula from local file
install FORMULA:
	brew install --formula ./Formula/{{FORMULA}}.rb

# Run a formula's test block
test FORMULA:
	brew test --formula ./Formula/{{FORMULA}}.rb

# Install, test, and uninstall in one go
check FORMULA:
	just install {{FORMULA}}
	just test {{FORMULA}}
	brew uninstall --formula ./Formula/{{FORMULA}}.rb

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

# Audit all formulae
audit-all:
	brew audit --strict --online