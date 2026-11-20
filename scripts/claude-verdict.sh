#!/usr/bin/env bash
# Exit non-zero unless Claude's bump verdict approves the PR.
# Usage: VERDICT='{"approve":true,"summary":"..."}' scripts/claude-verdict.sh
# The verdict is model output, so it goes only to the step summary, never to
# stdout, where GitHub would parse workflow commands like ::add-mask::.

set -euo pipefail

verdict="${VERDICT:-}"
summary_file="${GITHUB_STEP_SUMMARY:-/dev/null}"

if ! approve="$(jq -r '.approve | if type == "boolean" then tostring else error("no approve") end' \
   <<<"${verdict}" 2>/dev/null)" || [[ -z "${approve}" ]]
then
  echo "::error::Claude returned no valid verdict"
  exit 1
fi

{
  echo "### Claude bump review"
  echo
  echo "**Approved:** ${approve}"
  echo
  jq -r '.summary // ""' <<<"${verdict}"
} >>"${summary_file}"

if [[ "${approve}" != "true" ]]
then
  echo "::error::Claude rejected this bump. See the job summary for why."
  exit 1
fi
echo "Claude approved this bump"
