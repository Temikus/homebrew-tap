#!/usr/bin/env bash
# Rewrite Formula/<name>.rb for the latest (or given) upstream release.
# Usage: scripts/bump-formula.sh <formula-name> [tag] [--verify]
#   formula-name: formula file name without .rb extension
#   tag: optional specific tag (default: latest GitHub release or npm version)
#   --verify: verify the current formula matches the given tag (no changes)

set -euo pipefail

FORMULA_NAME="${1:-}"
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

if [[ -z "${FORMULA_NAME}" ]]
then
  echo "Usage: $0 <formula-name> [tag] [--verify]" >&2
  echo "  formula-name: formula file name without .rb extension" >&2
  echo "  tag: optional specific tag (default: latest GitHub release or npm version)" >&2
  echo "  --verify: verify current formula matches tag (no changes)" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${0}")/.." && pwd)"
FORMULA_FILE="${REPO_ROOT}/Formula/${FORMULA_NAME}.rb"

if [[ ! -f "${FORMULA_FILE}" ]]
then
  echo "Formula not found: ${FORMULA_FILE}" >&2
  exit 1
fi

# Verify mode runs the real bump in place, diffs, then always restores the
# original. This catches tag drift and checksums that no longer match upstream.
if [[ "${VERIFY}" == "true" ]]
then
  ORIGINAL=$(mktemp)
  cp "${FORMULA_FILE}" "${ORIGINAL}"
  restore_formula() {
    cp "${ORIGINAL}" "${FORMULA_FILE}"
    rm -f "${ORIGINAL}"
  }
  trap restore_formula EXIT
fi

finish() {
  if [[ "${VERIFY}" == "true" ]]
  then
    if diff -u "${ORIGINAL}" "${FORMULA_FILE}"
    then
      echo "${FORMULA_NAME} matches ${TAG} - OK"
      exit 0
    fi
    echo "${FORMULA_NAME} does not match ${TAG} (diff above)" >&2
    exit 1
  fi

  echo "Bumped ${FORMULA_NAME} to ${TAG}"
}

sha256_of_stdin() {
  if command -v sha256sum >/dev/null 2>&1
  then
    sha256sum | awk '{print $1}'
  else
    shasum -a 256 | awk '{print $1}'
  fi
}

TMP_FILE=$(mktemp)

# npm-published formulae have no GitHub release assets. The registry only
# publishes sha1/sha512 digests, so the tarball is downloaded for its sha256.
NPM_URL=$(sed -n 's|^  url "\(https://registry\.npmjs\.org/[^"]*\.tgz\)"$|\1|p' "${FORMULA_FILE}" | head -1)

if [[ -n "${NPM_URL}" ]]
then
  # https://registry.npmjs.org/@scope/name/-/name-1.2.3.tgz -> @scope/name
  NPM_PACKAGE="${NPM_URL#https://registry.npmjs.org/}"
  NPM_PACKAGE="${NPM_PACKAGE%%/-/*}"
  CURRENT_VERSION=$("${REPO_ROOT}/scripts/formula-tag.sh" "${FORMULA_FILE}")
  CURRENT_VERSION="${CURRENT_VERSION#v}"

  echo "Formula: ${FORMULA_NAME}"
  echo "Upstream: npm ${NPM_PACKAGE}"
  echo "Current version: ${CURRENT_VERSION}"

  if [[ -z "${TAG}" ]]
  then
    TAG="v$(curl -fsSL "https://registry.npmjs.org/${NPM_PACKAGE}/latest" | jq -r '.version // empty')"
    if [[ "${TAG}" == "v" ]]
    then
      echo "Could not resolve latest npm version" >&2
      exit 1
    fi
  fi
  VERSION="${TAG#v}"
  echo "Target version: ${VERSION}"

  NEW_URL="${NPM_URL%-"${CURRENT_VERSION}".tgz}-${VERSION}.tgz"
  SUM=$(curl -fsSL "${NEW_URL}" | sha256_of_stdin)

  awk -v old="${NPM_URL}" -v new="${NEW_URL}" -v sum="${SUM}" '
        $0 == "  url \"" old "\"" { $0 = "  url \"" new "\""; hit = 1 }
        hit && /^  sha256 / { $0 = "  sha256 \"" sum "\""; hit = 0 }
        { print }
    ' "${FORMULA_FILE}" >"${TMP_FILE}" && mv "${TMP_FILE}" "${FORMULA_FILE}"

  echo "  ${NEW_URL} ${SUM}"
  finish
  exit 0
fi

# Untagged upstreams pin a commit archive. The version is 0.0.<UTC commit time>,
# so newer commits sort higher and a later real release (0.1.0+) still wins.
# The tag is v<version>; it resolves to the pinned commit or the branch head.
ARCHIVE_URL=$(sed -n 's|^  url "\(https://github\.com/[^/]*/[^/]*/archive/[0-9a-f]\{40\}\.tar\.gz\)"$|\1|p' "${FORMULA_FILE}" | head -1)

if [[ -n "${ARCHIVE_URL}" ]]
then
  UPSTREAM_REPO=$(sed -n 's|^https://github\.com/\([^/]*/[^/]*\)/archive/.*|\1|p' <<<"${ARCHIVE_URL}")
  CURRENT_SHA=$(sed -n 's|.*/archive/\([0-9a-f]*\)\.tar\.gz$|\1|p' <<<"${ARCHIVE_URL}")
  CURRENT_VERSION=$(sed -n 's|^  version "\(.*\)"$|\1|p' "${FORMULA_FILE}" | head -1)
  BRANCH=$(sed -n 's|^  head ".*", branch: "\(.*\)"$|\1|p' "${FORMULA_FILE}" | head -1)
  BRANCH="${BRANCH:-main}"

  github_api() {
    if [[ -n "${GH_TOKEN:-}" ]]
    then
      curl -fsSL -H "Authorization: Bearer ${GH_TOKEN}" "https://api.github.com/repos/${UPSTREAM_REPO}/$1"
    else
      curl -fsSL "https://api.github.com/repos/${UPSTREAM_REPO}/$1"
    fi
  }

  echo "Formula: ${FORMULA_NAME}"
  echo "Upstream: ${UPSTREAM_REPO}@${BRANCH}"
  echo "Current version: ${CURRENT_VERSION} (${CURRENT_SHA})"

  if [[ -z "${TAG}" ]]
  then
    SHA=$(github_api "commits/${BRANCH}" | jq -r '.sha // empty')
  elif [[ "${TAG}" == "v${CURRENT_VERSION}" ]]
  then
    SHA="${CURRENT_SHA}"
  elif [[ "${TAG}" =~ ^[0-9a-f]{40}$ ]]
  then
    SHA="${TAG}"
  else
    echo "Cannot resolve ${TAG} to a commit; pass a full commit sha" >&2
    exit 1
  fi

  if [[ -z "${SHA}" ]]
  then
    echo "Could not resolve head of ${BRANCH}" >&2
    exit 1
  fi

  # 2026-11-02T10:26:14Z -> 20261102.1026
  COMMIT_TIME=$(github_api "commits/${SHA}" | jq -r '.commit.committer.date // empty')
  STAMP=$(sed -n 's|^\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)T\([0-9]\{2\}\):\([0-9]\{2\}\):.*Z$|\1\2\3.\4\5|p' <<<"${COMMIT_TIME}")
  if [[ -z "${STAMP}" ]]
  then
    echo "Could not read UTC commit time for ${SHA}: '${COMMIT_TIME}'" >&2
    exit 1
  fi

  VERSION="0.0.${STAMP}"
  TAG="v${VERSION}"
  echo "Target: ${VERSION} (${SHA})"

  NEW_URL="https://github.com/${UPSTREAM_REPO}/archive/${SHA}.tar.gz"
  SUM=$(curl -fsSL "${NEW_URL}" | sha256_of_stdin)

  awk -v old="${ARCHIVE_URL}" -v new="${NEW_URL}" -v ver="${VERSION}" -v sum="${SUM}" '
        $0 == "  url \"" old "\"" { $0 = "  url \"" new "\"" }
        /^  version "/ { $0 = "  version \"" ver "\"" }
        /^  sha256 "/ { $0 = "  sha256 \"" sum "\"" }
        { print }
    ' "${FORMULA_FILE}" >"${TMP_FILE}" && mv "${TMP_FILE}" "${FORMULA_FILE}"

  echo "  ${NEW_URL} ${SUM}"
  finish
  exit 0
fi

# Extract upstream repo from the release urls (homepage may point elsewhere)
UPSTREAM_REPO=$(sed -n 's|.*github\.com/\([^/]*/[^/]*\)/releases/download/.*|\1|p' "${FORMULA_FILE}" | head -1)

if [[ -z "${UPSTREAM_REPO}" ]]
then
  echo "Could not determine upstream repo from formula" >&2
  exit 1
fi

echo "Formula: ${FORMULA_NAME}"
echo "Upstream: ${UPSTREAM_REPO}"

# Resolve tag
if [[ -z "${TAG}" ]]
then
  TAG=$(curl -fsSL "https://api.github.com/repos/${UPSTREAM_REPO}/releases/latest" |
    sed -n 's/.*"tag_name": "\(.*\)".*/\1/p')
  if [[ -z "${TAG}" ]]
  then
    echo "Could not resolve latest release tag" >&2
    exit 1
  fi
fi

echo "Target tag: ${TAG}"

CURRENT_TAG=$(sed -n 's|.*/releases/download/\([^/]*\)/.*|\1|p' "${FORMULA_FILE}" | head -1)

if [[ -z "${CURRENT_TAG}" ]]
then
  echo "Could not determine current tag from formula" >&2
  exit 1
fi

echo "Current tag: ${CURRENT_TAG}"

# Rewriting only touches release URLs, so an archive URL or a stale tag on one
# platform would be silently carried forward (e.g. a partial Renovate bump).
STRAY_URLS=$(grep -E '^\s*url "' "${FORMULA_FILE}" | grep -v "/releases/download/${CURRENT_TAG}/" || true)
if [[ -n "${STRAY_URLS}" ]]
then
  echo "Every url must be a release asset for ${CURRENT_TAG}, found:" >&2
  echo "${STRAY_URLS}" >&2
  exit 1
fi

# Rewrite the tag everywhere it appears on a release URL line. Some projects
# embed the version in the asset filename too, not just the /download/<tag>/ path.
sed "\|/releases/download/|s|${CURRENT_TAG}|${TAG}|g" "${FORMULA_FILE}" >"${TMP_FILE}" &&
  mv "${TMP_FILE}" "${FORMULA_FILE}"

# Asset filenames the formula now points at
ASSET_LIST=$(sed -n 's|.*/releases/download/[^/]*/\([^"]*\)".*|\1|p' "${FORMULA_FILE}" | sort -u)
ASSETS=()
while IFS= read -r asset
do
  [[ -n "${asset}" ]] && ASSETS+=("${asset}")
done <<<"${ASSET_LIST}"

if [[ ${#ASSETS[@]} -eq 0 ]]
then
  echo "No release assets found in formula" >&2
  exit 1
fi

echo "Updating checksums for: ${ASSETS[*]}"

# Some projects publish one sha256sums.txt for the whole release, others a
# .sha256 next to each asset. Try both before falling back to downloading.
SUMS_FILE=$(curl -fsSL "https://github.com/${UPSTREAM_REPO}/releases/download/${TAG}/sha256sums.txt" 2>/dev/null || true)

for asset in "${ASSETS[@]}"
do
  SUM=""

  if [[ -n "${SUMS_FILE}" ]]
  then
    # Checksum files may prefix the filename with * for binary mode
    SUM=$(awk -v f="${asset}" '$2 == f || $2 == "*" f {print $1; exit}' <<<"${SUMS_FILE}")
  fi

  if [[ -z "${SUM}" ]]
  then
    SUM=$(curl -fsSL "https://github.com/${UPSTREAM_REPO}/releases/download/${TAG}/${asset}.sha256" 2>/dev/null | awk '{print $1}' || true)
  fi

  if [[ -z "${SUM}" ]]
  then
    echo "  no published checksum for ${asset}, downloading to compute" >&2
    SUM=$(curl -fsSL "https://github.com/${UPSTREAM_REPO}/releases/download/${TAG}/${asset}" | sha256_of_stdin)
  fi

  if [[ -z "${SUM}" ]]
  then
    echo "Could not determine checksum for ${asset}" >&2
    exit 1
  fi

  # Replace the sha256 on the line following this asset's url
  awk -v marker="/${asset}\"" -v sum="${SUM}" '
        hit { sub(/sha256 "[0-9a-f]*"/, "sha256 \"" sum "\""); hit = 0 }
        index($0, marker) { hit = 1 }
        { print }
    ' "${FORMULA_FILE}" >"${TMP_FILE}" && mv "${TMP_FILE}" "${FORMULA_FILE}"

  echo "  ${asset} ${SUM}"
done

finish
