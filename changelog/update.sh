#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${RELEASE_TAG:-}" ]]; then
  echo '::error::latest-version is required.'
  exit 1
fi

tool_dir=$(mktemp -d "${RUNNER_TEMP:?}/hsf-changelog.XXXXXX")
trap 'rm -rf "$tool_dir"' EXIT

# Upstream action v1.13.0 / CLI v1.13. Pin both the source commit and bytes.
curl --fail --silent --show-error --location --retry 3 \
  https://raw.githubusercontent.com/stefanzweifel/changelog-updater-action/1171d74932456fd2049c486b8757956a6adcc11b/changelog-updater \
  --output "$tool_dir/changelog-updater"

php -r '
  if (hash_file("sha256", $argv[1]) !== "993de72375a723a7a88bb327d9b2d8fc5cb5da0a0cdae2286c93133468d5d133") {
    fwrite(STDERR, "Changelog updater checksum mismatch.\n");
    exit(1);
  }
' "$tool_dir/changelog-updater"

php "$tool_dir/changelog-updater" update \
  --latest-version="$RELEASE_TAG" \
  --release-notes="${RELEASE_NOTES:-}" \
  --path-to-changelog="${CHANGELOG_PATH:-CHANGELOG.md}" \
  --release-date="${RELEASE_DATE:-}" \
  --write \
  --no-interaction
