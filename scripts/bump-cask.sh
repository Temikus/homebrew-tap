#!/usr/bin/env bash
# Rewrite Casks/<name>.rb for the latest (or given) upstream release.
# Usage: scripts/bump-cask.sh <cask-name> [tag] [--verify]
#   cask-name: cask file name without .rb extension
#   tag: optional specific tag (default: latest from GitHub releases)
#   --verify: verify the current cask matches the given tag (no changes)
#
# Expects a GitHub release url templated on #{version} and optionally #{arch},
# with either `sha256 "<sum>"` or `sha256 arm: "<sum>", intel: "<sum>"`.

set -euo pipefail

CASK_NAME="${1:-}"
TAG="${2:-}"
VERIFY=false

if [[ "${3:-}" == "--verify" ]] || [[ "${2:-}" == "--verify" ]]
then
  VERIFY=true
  if [[ "${2:-}" == "--verify" ]]
  then
    TAG=""
  fi
fi

if [[ -z "${CASK_NAME}" ]]
then
  echo "Usage: $0 <cask-name> [tag] [--verify]" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${0}")/.." && pwd)"
CASK_FILE="${REPO_ROOT}/Casks/${CASK_NAME}.rb"

if [[ ! -f "${CASK_FILE}" ]]
then
  echo "Cask not found: ${CASK_FILE}" >&2
  exit 1
fi

URL=$(sed -n 's|^  url "\(https://github\.com/[^"]*/releases/download/[^"]*\)".*|\1|p' "${CASK_FILE}" | head -1)
UPSTREAM_REPO=$(sed -n 's|https://github\.com/\([^/]*/[^/]*\)/releases/download/.*|\1|p' <<<"${URL}")
# Release path segment, e.g. v#{version}
TAG_TEMPLATE=$(sed -n 's|.*/releases/download/\([^/]*\)/.*|\1|p' <<<"${URL}")
ASSET_TEMPLATE="${URL##*/}"

if [[ -z "${UPSTREAM_REPO}" ]] || [[ "${TAG_TEMPLATE}" != *'#{version}'* ]]
then
  echo "Cask url must be a GitHub release asset templated on #{version}" >&2
  exit 1
fi

TAG_PREFIX="${TAG_TEMPLATE%%'#{version}'*}"
TAG_SUFFIX="${TAG_TEMPLATE#*'#{version}'}"

echo "Cask: ${CASK_NAME}"
echo "Upstream: ${UPSTREAM_REPO}"

api() {
  local auth=()
  if [[ -n "${GH_TOKEN:-}" ]]
  then
    auth=(-H "Authorization: Bearer ${GH_TOKEN}")
  fi
  # Expansion guard: bash 3.2 treats an empty array as unbound under set -u
  curl -fsSL ${auth[@]+"${auth[@]}"} -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${UPSTREAM_REPO}/$1"
}

if [[ -z "${TAG}" ]]
then
  RELEASE_JSON=$(api releases/latest)
  TAG=$(jq -r .tag_name <<<"${RELEASE_JSON}")
else
  RELEASE_JSON=$(api "releases/tags/${TAG}")
fi

VERSION="${TAG#"${TAG_PREFIX}"}"
VERSION="${VERSION%"${TAG_SUFFIX}"}"

if [[ -z "${VERSION}" ]] || [[ "${TAG_PREFIX}${VERSION}${TAG_SUFFIX}" != "${TAG}" ]]
then
  echo "Tag ${TAG} does not fit url template ${TAG_TEMPLATE}" >&2
  exit 1
fi

echo "Target tag: ${TAG} (version ${VERSION})"

if [[ "${VERIFY}" == "true" ]]
then
  echo "Verifying cask matches ${TAG}..."
  ORIGINAL=$(mktemp)
  cp "${CASK_FILE}" "${ORIGINAL}"
  restore_cask() {
    cp "${ORIGINAL}" "${CASK_FILE}"
    rm -f "${ORIGINAL}"
  }
  trap restore_cask EXIT
fi

sha256_of_stdin() {
  if command -v sha256sum >/dev/null 2>&1
  then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

checksum_for() {
  local asset="$1" sum
  # GitHub computes digests for assets uploaded since mid-2025; older ones have null
  sum=$(jq -r --arg name "${asset}" '.assets[] | select(.name == $name) | .digest // empty' <<<"${RELEASE_JSON}")
  sum="${sum#sha256:}"
  if [[ -z "${sum}" ]]
  then
    echo "  no digest for ${asset}, downloading to compute" >&2
    sum=$(curl -fsSL "https://github.com/${UPSTREAM_REPO}/releases/download/${TAG}/${asset}" | sha256_of_stdin)
  fi
  if [[ ! "${sum}" =~ ^[0-9a-f]{64}$ ]]
  then
    echo "Could not determine checksum for ${asset}" >&2
    exit 1
  fi
  echo "${sum}"
}

asset_for() {
  local asset="${ASSET_TEMPLATE//'#{version}'/${VERSION}}"
  echo "${asset//'#{arch}'/$1}"
}

TMP_FILE=$(mktemp)
sed "s|^  version \".*\"|  version \"${VERSION}\"|" "${CASK_FILE}" >"${TMP_FILE}" &&
  mv "${TMP_FILE}" "${CASK_FILE}"

if [[ "${ASSET_TEMPLATE}" == *'#{arch}'* ]]
then
  for key in arm intel
  do
    arch_value=$(sed -n "s/^  arch .*${key}: \"\([^\"]*\)\".*/\1/p" "${CASK_FILE}")
    if [[ -z "${arch_value}" ]]
    then
      echo "No ${key} value in arch stanza" >&2
      exit 1
    fi
    asset=$(asset_for "${arch_value}")
    sum=$(checksum_for "${asset}")
    # Only touch lines already holding a sha256, not the `arch` stanza
    sed -E "/[0-9a-f]{64}/s/(${key}:[[:space:]]*)\"[0-9a-f]{64}\"/\1\"${sum}\"/" "${CASK_FILE}" >"${TMP_FILE}" &&
      mv "${TMP_FILE}" "${CASK_FILE}"
    echo "  ${asset} ${sum}"
  done
else
  asset=$(asset_for "")
  sum=$(checksum_for "${asset}")
  sed -E "s/^(  sha256 )\"[0-9a-f]{64}\"/\1\"${sum}\"/" "${CASK_FILE}" >"${TMP_FILE}" &&
    mv "${TMP_FILE}" "${CASK_FILE}"
  echo "  ${asset} ${sum}"
fi

if [[ "${VERIFY}" == "true" ]]
then
  if diff -u "${ORIGINAL}" "${CASK_FILE}"
  then
    echo "${CASK_NAME} matches ${TAG} - OK"
    exit 0
  fi
  echo "${CASK_NAME} does not match ${TAG} (diff above)" >&2
  exit 1
fi

echo "Bumped ${CASK_NAME} to ${TAG}"
