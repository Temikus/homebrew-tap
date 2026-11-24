#!/usr/bin/env bash
# Real `brew upgrade` of openrig from FROM_VERSION to the tap's formula.
# Usage: run.sh daemon|no-daemon [FROM_VERSION]
#   daemon:    start a daemon with 3 stub seats on FROM_VERSION, upgrade, then
#              check the old keg is gone and a restart keeps the seats.
#   no-daemon: upgrade with no daemon; nothing starts.
# This installs and upgrades the real openrig keg, so it refuses to run outside
# CI unless OPENRIG_UPGRADE_TEST_OK=1.

set -euo pipefail

SCENARIO="${1:?usage: run.sh daemon|no-daemon [FROM_VERSION]}"
FROM="${2:-}"
FIXTURE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${FIXTURE}/../.." && pwd)"
FORMULA="${REPO_ROOT}/Formula/openrig.rb"

if [[ -z "${CI:-}" && "${OPENRIG_UPGRADE_TEST_OK:-}" != "1" ]]
then
  echo "This replaces the installed openrig keg. Set OPENRIG_UPGRADE_TEST_OK=1 to run it here." >&2
  exit 2
fi

export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1 HOMEBREW_NO_ENV_HINTS=1
unset HOMEBREW_NO_INSTALL_CLEANUP

WORK="$(mktemp -d)"
export OPENRIG_HOME="${WORK}/home"
mkdir -p "${OPENRIG_HOME}" "${WORK}/project"
cp -R "${FIXTURE}/rig.yaml" "${FIXTURE}/agents" "${WORK}/"
BIN="$(brew --prefix)/bin"
CELLAR="$(brew --cellar)"

TO="$("${REPO_ROOT}/scripts/formula-tag.sh" "${FORMULA}")"
TO="${TO#v}"
if [[ -z "${FROM}" ]]
then
  # The newest stable npm release older than the formula's version.
  FROM="$(curl -fsSL https://registry.npmjs.org/@openrig/cli | jq -r --arg to "${TO}" '
    def v: split(".") | map(tonumber);
    [.versions | keys[] | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$")) | select(v < ($to | v))]
    | sort_by(v) | last // empty')"
fi
[[ -n "${FROM}" ]] || { echo "No version older than ${TO} on npm" >&2; exit 1; }
echo "Scenario ${SCENARIO}: ${FROM} -> ${TO}"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

healthz() {
  local port
  port="$(jq -r .port "${OPENRIG_HOME}/daemon.json")"
  curl -fsS "http://127.0.0.1:${port}/healthz"
}

dump_logs() {
  echo "--- daemon.log (last 80 lines)"
  tail -n 80 "${OPENRIG_HOME}/daemon.log" 2>/dev/null || true
}
trap dump_logs ERR

# Install FROM: the tap's own formula, pinned to the older npm release.
cp "${FORMULA}" "${WORK}/openrig.rb.to"
"${REPO_ROOT}/scripts/bump-formula.sh" openrig "v${FROM}" >/dev/null
if brew list --formula openrig >/dev/null 2>&1
then
  brew uninstall --formula openrig
fi
brew install --formula temikus/tap/openrig
cp "${WORK}/openrig.rb.to" "${FORMULA}"
[[ -d "${CELLAR}/openrig/${FROM}" ]] || fail "openrig ${FROM} keg not installed"

if [[ "${SCENARIO}" == "daemon" ]]
then
  "${BIN}/rig" daemon start --no-kernel
  [[ "$(healthz | jq -r .semver)" == "${FROM}" ]] || fail "daemon is not ${FROM} before the upgrade"
  "${BIN}/rig" up "${WORK}/rig.yaml" --cwd "${WORK}/project" --yes --json >/dev/null
  tmux list-panes -a -F '#{session_name} #{pane_pid}' | sort >"${WORK}/panes.before"
  [[ "$(wc -l <"${WORK}/panes.before")" -ge 3 ]] || fail "expected 3 tmux seats, got: $(cat "${WORK}/panes.before")"
  pass "daemon ${FROM} running with seats: $(awk '{print $1}' "${WORK}/panes.before" | xargs)"
fi

brew upgrade --formula temikus/tap/openrig 2>&1 | tee "${WORK}/upgrade.log" || fail "brew upgrade exited non-zero"
pass "brew upgrade exited 0"
[[ ! -d "${CELLAR}/openrig/${FROM}" ]] || fail "old keg ${FROM} still present; cleanup did not run"
pass "cleanup removed the ${FROM} keg"
grep -qF "rig daemon stop && rig daemon start" "${WORK}/upgrade.log" || fail "caveat not printed"
pass "caveat printed"

if [[ "${SCENARIO}" == "no-daemon" ]]
then
  [[ ! -e "${OPENRIG_HOME}/daemon.json" ]] || fail "upgrade started a daemon"
  ! pgrep -f "openrig/.*/daemon/dist/index.js" >/dev/null || fail "a daemon process is running"
  pass "no daemon started"
  exit 0
fi

[[ "$(healthz | jq -r .semver)" == "${FROM}" ]] || fail "daemon is not still ${FROM} after the upgrade"
pass "daemon still reports ${FROM} until restarted"

log_offset="$(wc -c <"${OPENRIG_HOME}/daemon.log")"
"${BIN}/rig" daemon stop
"${BIN}/rig" daemon start --no-kernel

health="$(healthz)"
[[ "$(jq -r .semver <<<"${health}")" == "${TO}" ]] || fail "daemon reports $(jq -r .semver <<<"${health}"), want ${TO}"
pass "/healthz 200, semver ${TO}"
tmux list-panes -a -F '#{session_name} #{pane_pid}' | sort >"${WORK}/panes.after"
diff -u "${WORK}/panes.before" "${WORK}/panes.after" || fail "tmux seats changed across the restart"
pass "tmux seats unchanged"
if tail -c "+$((log_offset + 1))" "${OPENRIG_HOME}/daemon.log" | grep -E "ENOENT|ERR_MODULE_NOT_FOUND"
then
  fail "daemon log mentions a missing file after the restart"
fi
pass "no ENOENT in the daemon log after the restart"

"${BIN}/rig" down upgrade-test --force --json >/dev/null || true
"${BIN}/rig" daemon stop || true
