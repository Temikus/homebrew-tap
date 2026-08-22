#!/usr/bin/env bash
# Rewrite Formula/<name>.rb for the latest (or given) upstream release.
# Usage: scripts/bump-formula.sh <formula-name> [tag] [--verify]
#   formula-name: formula file name without .rb extension
#   tag: optional specific tag (default: latest from GitHub releases)
#   --verify: verify the current formula matches the given tag (no changes)

set -euo pipefail

FORMULA_NAME="${1:-}"
TAG="${2:-}"
VERIFY=false

if [[ "${3:-}" == "--verify" ]] || [[ "${2:-}" == "--verify" ]]; then
    VERIFY=true
    if [[ "${2:-}" == "--verify" ]]; then
        TAG=""
    fi
fi

if [[ -z "${FORMULA_NAME}" ]]; then
    echo "Usage: $0 <formula-name> [tag] [--verify]" >&2
    echo "  formula-name: formula file name without .rb extension" >&2
    echo "  tag: optional specific tag (default: latest from GitHub releases)" >&2
    echo "  --verify: verify current formula matches tag (no changes)" >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${0}")/.." && pwd)"
FORMULA_FILE="${REPO_ROOT}/Formula/${FORMULA_NAME}.rb"

if [[ ! -f "${FORMULA_FILE}" ]]; then
    echo "Formula not found: ${FORMULA_FILE}" >&2
    exit 1
fi

# Extract upstream repo from formula's homepage or url
UPSTREAM_REPO=$(grep -E 'homepage|url' "${FORMULA_FILE}" | head -1 | sed -E 's|.*github\.com/([^/]+/[^/]+).*|\1|' | sed 's/\.git$//')

if [[ -z "${UPSTREAM_REPO}" ]]; then
    echo "Could not determine upstream repo from formula" >&2
    exit 1
fi

echo "Formula: ${FORMULA_NAME}"
echo "Upstream: ${UPSTREAM_REPO}"

# Resolve tag
if [[ -z "${TAG}" ]]; then
    TAG=$(curl -fsSL "https://api.github.com/repos/${UPSTREAM_REPO}/releases/latest" |
        sed -n 's/.*"tag_name": "\(.*\)".*/\1/p')
    if [[ -z "${TAG}" ]]; then
        echo "Could not resolve latest release tag" >&2
        exit 1
    fi
fi

echo "Target tag: ${TAG}"

if [[ "${VERIFY}" == "true" ]]; then
    echo "Verifying formula matches ${TAG}..."
    # Create temp copy, bump it, compare
    TMP_FORMULA=$(mktemp)
    cp "${FORMULA_FILE}" "${TMP_FORMULA}"
    # We need to run the bump logic on the temp file
    # For verification, we'll just check if the tag in the formula matches
    CURRENT_TAG=$(sed -n 's|.*/releases/download/\([^/]*\)/.*|\1|p' "${FORMULA_FILE}" | head -1)
    if [[ "${CURRENT_TAG}" == "${TAG}" ]]; then
        echo "Formula already at ${TAG} - OK"
        rm -f "${TMP_FORMULA}"
        exit 0
    else
        echo "Formula at ${CURRENT_TAG}, expected ${TAG}" >&2
        rm -f "${TMP_FORMULA}"
        exit 1
    fi
fi

# Write via temp file (BSD/GNU sed compatible)
TMP_FILE=$(mktemp)
sed -E "s|/releases/download/[^/]+/|/releases/download/${TAG}/|g" "${FORMULA_FILE}" >"${TMP_FILE}" &&
    mv "${TMP_FILE}" "${FORMULA_FILE}"

# Update checksums for each platform
# Detect platforms from the formula
PLATFORMS=()
while IFS= read -r line; do
    if [[ "${line}" =~ fx-([a-z0-9-]+)\.tar\.gz ]]; then
        PLATFORMS+=("${BASH_REMATCH[1]}")
    fi
done < <(grep -o 'fx-[a-z0-9-]*\.tar\.gz' "${FORMULA_FILE}" | sort -u)

# If no fx- pattern, try generic pattern
if [[ ${#PLATFORMS[@]} -eq 0 ]]; then
    while IFS= read -r line; do
        if [[ "${line}" =~ ([a-z0-9-]+)\.tar\.gz ]]; then
            PLATFORMS+=("${BASH_REMATCH[1]}")
        fi
    done < <(grep -o '[a-z0-9-]*\.tar\.gz' "${FORMULA_FILE}" | grep -v '^fx-' | sort -u)
fi

# Default platforms if detection fails
if [[ ${#PLATFORMS[@]} -eq 0 ]]; then
    PLATFORMS=(macos-aarch64 macos-x86_64 linux-aarch64 linux-x86_64)
fi

echo "Updating checksums for platforms: ${PLATFORMS[*]}"

for target in "${PLATFORMS[@]}"; do
    # Try to find the asset name pattern in the formula
    ASSET_NAME=$(grep -o "${target}\.tar\.gz" "${FORMULA_FILE}" | head -1 | sed 's/\.tar\.gz$//')
    if [[ -z "${ASSET_NAME}" ]]; then
        # Try to infer from formula name
        ASSET_NAME="${FORMULA_NAME}-${target}"
    fi
    
    SUM=$(curl -fsSL "https://github.com/${UPSTREAM_REPO}/releases/download/${TAG}/${ASSET_NAME}.tar.gz.sha256" 2>/dev/null | awk '{print $1}')
    
    if [[ -z "${SUM}" ]]; then
        # Try alternative naming
        SUM=$(curl -fsSL "https://github.com/${UPSTREAM_REPO}/releases/download/${TAG}/${FORMULA_NAME}-${target}.tar.gz.sha256" 2>/dev/null | awk '{print $1}')
    fi
    
    if [[ -z "${SUM}" ]]; then
        echo "Warning: no checksum published for ${target} (tried ${ASSET_NAME}.tar.gz.sha256 and ${FORMULA_NAME}-${target}.tar.gz.sha256)" >&2
        continue
    fi
    
    # Replace the sha256 on the line after this target's url
    awk -v marker="${ASSET_NAME}.tar.gz\"" -v sum="${SUM}" '
        hit { sub(/sha256 "[0-9a-f]*"/, "sha256 \"" sum "\""); hit = 0 }
        index($0, marker) { hit = 1 }
        { print }
    ' "${FORMULA_FILE}" >"${TMP_FILE}" && mv "${TMP_FILE}" "${FORMULA_FILE}"
    
    echo "  ${target} ${SUM}"
done

echo "Bumped ${FORMULA_NAME} to ${TAG}"