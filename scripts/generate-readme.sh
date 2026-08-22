#!/usr/bin/env bash
# Generate README.md from Formula/*.rb files

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${0}")/.." && pwd)"
README_FILE="${REPO_ROOT}/README.md"
TMP_README=$(mktemp)

cat >"${TMP_README}" <<'EOF'
# temikus/tap

[![CI](https://github.com/temikus/tap/actions/workflows/ci.yml/badge.svg)](https://github.com/temikus/tap/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

General-purpose Homebrew tap for miscellaneous tools I want to keep for myself and share with others.

## Install

```bash
brew tap temikus/tap
brew install temikus/tap/<formula>
```

Or without tapping first:

```bash
brew install temikus/tap/<formula>
```

Recent Homebrew versions ask you to trust a third-party tap before installing from it:

```bash
brew trust temikus/tap
```

## Formulae

| Formula | Version | Description | Install |
|---------|---------|-------------|---------|
EOF

# Process each formula
for formula_file in "${REPO_ROOT}"/Formula/*.rb; do
    [[ -f "${formula_file}" ]] || continue
    
    name=$(basename "${formula_file}" .rb)
    
    # Extract version from url (tag in release URL)
    version=$(grep -o '/releases/download/[^/]*' "${formula_file}" | head -1 | sed 's|.*/releases/download/||')
    [[ -z "${version}" ]] && version="unknown"
    
    # Extract desc
    desc=$(grep '^  desc ' "${formula_file}" | sed 's/^  desc "//; s/"$//')
    [[ -z "${desc}" ]] && desc="No description"
    
    # Extract homepage
    homepage=$(grep '^  homepage ' "${formula_file}" | sed 's/^  homepage "//; s/"$//')
    [[ -z "${homepage}" ]] && homepage="https://github.com/temikus/tap"
    
    printf "| [%s](%s) | %s | %s | \`brew install temikus/tap/%s\` |\n" \
        "${name}" "${homepage}" "${version}" "${desc}" "${name}" >>"${TMP_README}"
done

cat >>"${TMP_README}" <<'EOF'

## Maintenance

Requires [`just`](https://github.com/casey/just):

| Command | What it does |
| --- | --- |
| `just audit [FORMULA]` | `brew audit --strict --online` against formula(s) |
| `just install FORMULA` | Install from local formula file |
| `just test FORMULA` | Run the formula's `test do` block |
| `just check FORMULA` | Install, test, and uninstall |
| `just style` | Lint the tap the way CI does |
| `just bump FORMULA` | Rewrite formula for latest upstream release |
| `just verify-bump FORMULA` | Check bump script reproduces pinned formula exactly |
| `just generate-readme` | Regenerate this README from formulae |
| `just audit-all` | Audit all formulae |

## CI / Automation

- **CI** (`.github/workflows/ci.yml`): Runs on every push/PR — syntax check, style, audit, test on macOS 14/15 + Ubuntu
- **Auto-bump** (`.github/workflows/autobump.yml`): Daily check for upstream updates, opens PRs
- **Scheduled** (`.github/workflows/scheduled.yml`): Weekly full audit
- **Security** (`.github/workflows/security.yml`): Secret scanning, dependency review

## License

The tap is Apache-2.0. Individual formulae retain their upstream licenses.

EOF

mv "${TMP_README}" "${README_FILE}"
echo "Generated ${README_FILE}"