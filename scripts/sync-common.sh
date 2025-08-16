#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <child-repo-path> [<child-repo-path> ...]"
  exit 1
fi

COMMON_FILES=(
  ".gitattributes"
  ".gitignore"
  ".editorconfig"
  ".github/CODEOWNERS"
  ".github/ISSUE_TEMPLATE/bug_report.md"
  ".github/ISSUE_TEMPLATE/feature_request.md"
  ".github/ISSUE_TEMPLATE/task.md"
  ".github/pull_request_template.md"
  ".github/workflows/lint.yml"
  ".github/dependabot.yml"
  ".github/renovate.json"
  "LICENSE"
)

for dst in "$@"; do
  echo ">>> Sync to $dst"
  for f in "${COMMON_FILES[@]}"; do
    mkdir -p "$(dirname "$dst/$f")"
    cp -a "$f" "$dst/$f"
  done
done

echo "Done."
