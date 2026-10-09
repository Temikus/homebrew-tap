#!/usr/bin/env bash
# Print the upstream tag a formula is pinned to.
# Usage: scripts/formula-tag.sh Formula/<name>.rb
# npm tarball urls carry no tag, so their version is printed as v<version>.

set -euo pipefail

FORMULA_FILE="${1:?Usage: $0 Formula/<name>.rb}"

tag=$(sed -n 's|.*/releases/download/\([^/]*\)/.*|\1|p' "${FORMULA_FILE}" | head -1)

if [[ -z "${tag}" ]]
then
  version=$(sed -n 's|^  url "https://registry\.npmjs\.org/.*/-/.*-\([0-9][^"]*\)\.tgz"$|\1|p' "${FORMULA_FILE}" | head -1)
  [[ -n "${version}" ]] && tag="v${version}"
fi

if [[ -z "${tag}" ]]
then
  echo "Could not read a release or npm url from ${FORMULA_FILE}" >&2
  exit 1
fi

echo "${tag}"
