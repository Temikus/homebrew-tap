# temikus/tap

[![CI](https://github.com/temikus/homebrew-tap/actions/workflows/ci.yml/badge.svg)](https://github.com/temikus/homebrew-tap/actions/workflows/ci.yml)
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
| [fx](https://github.com/vercel-labs/fx) | v0.0.5 | Tiny, open, embeddable, native coding agent | `brew install temikus/tap/fx` |
| [maki](https://maki.sh) | v0.4.11 | AI coding agent for the terminal, extendable by neovim-like Lua plugins | `brew install temikus/tap/maki` |

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

