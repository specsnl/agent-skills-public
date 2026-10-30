#!/usr/bin/env bash
set -euo pipefail

# Collects all issues referenced in a GitHub release and writes them, with
# their comments and linked pull requests, to one Markdown file. That file
# is the input for writing release notes / changelog.

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/get-release-issues.sh RELEASE_TAG

Fetches a GitHub release's body and finds every pull request listed under
"What's Changed" whose title follows the conventional-commit pattern
"type(ISSUE_NUMBER): ..." (e.g. "feat(7807): ..."). For each referenced
issue number, writes its full details. Each issue's block also includes the
descriptions of pull requests linked to it via GitHub's closing references
(e.g. "Fixes #123").
Pull requests titled "feat: ..." or "fix: ..." (without an issue number) are
included as well, with their own description.
The repository is the GitHub repo of the current directory.
The output is written to RELEASE_TAG-issues.md.

Example:
  ./scripts/get-release-issues.sh v3.7.0-rc.1
USAGE
}

# Argument and dependency checks.
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI 'gh' is not installed or is not on PATH." >&2
  exit 1
fi

release="$1"

# Repository to read from: the GitHub repo of the current directory.
IFS=$'\t' read -r OWNER REPO < <(
  gh repo view --json owner,name --jq '[.owner.login, .name] | @tsv'
)

output="${release}-issues.md"

# Fetch the release description (the "What's Changed" list of PRs).
body="$(
  gh release view "$release" \
    -R "$OWNER/$REPO" \
    --json body \
    --jq '.body // ""'
)"

# Write to temp files first, so a failed run never leaves a half-written output.
tmp="$(mktemp "${output}.tmp.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

sections="$(mktemp "${output}.sections.tmp.XXXXXX")"
trap 'rm -f "$tmp" "$sections"' EXIT

# Extract issue numbers from release lines like "* feat(7807): ..." or
# "- fix(7807, 7810): ..." (bullet may be * or -). Each number is stored as one line in $sections.
prs=()
while IFS= read -r line || [[ -n "$line" ]]; do
  # Strip a possible byte order mark.
  line="${line#$'﻿'}"

  matches="$(
    printf '%s\n' "$line" \
      | grep -oE '^[*-][[:space:]]*[[:alpha:]]+\([0-9]+(,[[:space:]]*[0-9]+)*\):' \
      | grep -oE '[0-9]+' || true
  )"

  # Lines like "- feat: ..." or "- fix: ..." have no issue number; remember
  # the PR number so the PR itself can be included.
  if [[ -z "$matches" ]]; then
    if [[ "$line" =~ ^[*-][[:space:]]*(feat|fix):.*/pull/([0-9]+) ]]; then
      prs+=("${BASH_REMATCH[2]}")
    fi
    continue
  fi

  while IFS= read -r mentioned_issue; do
    if [[ -n "$mentioned_issue" ]]; then
      printf '0\t%s\t\n' "$mentioned_issue" >> "$sections"
    fi
  done <<< "$matches"
done <<< "$body"

# For each unique issue: write title, status, URL, description and comments,
# followed by the pull requests that close it (with their descriptions).
: > "$tmp"
issue_count=0
while IFS=$'\t' read -r _section_order mentioned_issue _section; do
  issue_count=$((issue_count + 1))
  echo "Fetching #$mentioned_issue..." >&2

  gh issue view "$mentioned_issue" \
    -R "$OWNER/$REPO" \
    --json number,title,state,url,body,comments \
    --jq '
      "## #\(.number) \(.title) [\(.state)]",
      "",
      "\(.url)",
      "",
      (.body // ""),
      "",
      "### Comments",
      (
        if (.comments | length) == 0 then
          "_No comments_"
        else
          .comments[] | "- @\(.author.login): \(.body)"
        end
      ),
      ""
    ' >> "$tmp"

  # Linked PRs are only available through the GraphQL API.
  gh api graphql \
    -f query='
      query($owner: String!, $repo: String!, $number: Int!) {
        repository(owner: $owner, name: $repo) {
          issue(number: $number) {
            closedByPullRequestsReferences(first: 20, includeClosedPrs: true) {
              nodes { number title state url body }
            }
          }
        }
      }' \
    -f owner="$OWNER" -f repo="$REPO" -F number="$mentioned_issue" \
    --jq '
      "### Related Pull Requests",
      "",
      (
        .data.repository.issue.closedByPullRequestsReferences.nodes as $prs |
        if ($prs | length) == 0 then
          "_No related pull requests_"
        else
          $prs[] | "#### #\(.number) \(.title) [\(.state)]", "", "\(.url)", "", (.body // ""), ""
        end
      )
    ' >> "$tmp"
done < <(
  # Deduplicate: an issue mentioned in several PRs is fetched only once.
  awk -F '\t' '!seen[$1 FS $2]++ { print }' "$sections"
)

# Append the feat/fix pull requests without an issue number.
for pr in "${prs[@]}"; do
  echo "Fetching PR #$pr..." >&2

  gh pr view "$pr" \
    -R "$OWNER/$REPO" \
    --json number,title,state,url,body \
    --jq '
      "## PR #\(.number) \(.title) [\(.state)] (no issue)",
      "",
      "\(.url)",
      "",
      (.body // ""),
      ""
    ' >> "$tmp"
done

if [[ "$issue_count" -eq 0 && ${#prs[@]} -eq 0 ]]; then
  echo "Error: no issue numbers or feat/fix pull requests found in release $release." >&2
  exit 1
fi

# Everything succeeded: move the result to the final output file.
mv "$tmp" "$output"
rm -f "$sections"
trap - EXIT

echo "Wrote $issue_count issues and ${#prs[@]} pull requests to $output"
