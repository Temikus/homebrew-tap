#!/usr/bin/env bash
# Print the upstream release tag a cask is pinned to.
# Usage: scripts/cask-tag.sh Casks/<name>.rb

set -euo pipefail

CASK_FILE="${1:?Usage: $0 Casks/<name>.rb}"

version=$(sed -n 's/^  version "\(.*\)"$/\1/p' "${CASK_FILE}" | head -1)
template=$(sed -n 's|^  url ".*/releases/download/\([^/]*\)/.*|\1|p' "${CASK_FILE}" | head -1)

if [[ -z "${version}" ]] || [[ -z "${template}" ]]
then
  echo "Could not read version or release url from ${CASK_FILE}" >&2
  exit 1
fi

echo "${template//'#{version}'/${version}}"
