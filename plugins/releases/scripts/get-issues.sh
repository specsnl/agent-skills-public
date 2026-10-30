#!/usr/bin/env bash
set -euo pipefail

OWNER="${OWNER:-minvws}"
REPO="${REPO:-nl-rdo-woo-web-private}"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/get-issues.sh ISSUE_NUMBER [OUTPUT_FILE]

When ISSUE_NUMBER is a Task, fetch that issue itself. For other issue types,
find mentioned issues under section headers and write their full details.
Each issue's block also includes the descriptions of pull requests linked to
it via GitHub's closing references (e.g. "Fixes #123").
When OUTPUT_FILE is omitted, the script writes to ISSUE_NUMBER.md.

Examples:
  ./scripts/get-issues.sh 1234
  ./scripts/get-issues.sh 1234 mentioned-issues.md

Environment:
  OWNER  GitHub owner/org. Defaults to minvws.
  REPO   GitHub repository. Defaults to nl-rdo-woo-web-private.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 2
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI 'gh' is not installed or is not on PATH." >&2
  exit 1
fi

issue="$1"
output="${2:-${issue}.md}"

issue_data="$(
  gh issue view "$issue" \
    -R "$OWNER/$REPO" \
    --json body,issueType \
    --jq '(.issueType.name // ""), (.body // "")'
)"

issue_type="${issue_data%%$'\n'*}"
if [[ "$issue_data" == *$'\n'* ]]; then
  body="${issue_data#*$'\n'}"
else
  body=""
fi

tmp="$(mktemp "${output}.tmp.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

sections="$(mktemp "${output}.sections.tmp.XXXXXX")"
trap 'rm -f "$tmp" "$sections"' EXIT

if [[ "$issue_type" == "Task" ]]; then
  printf '0\t%s\t\n' "$issue" >> "$sections"
else
  current_section=""
  current_section_order=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#$'\ufeff'}"

    if [[ "$line" =~ ^####[[:space:]]+(.+) ]]; then
      current_section="${BASH_REMATCH[1]}"
      current_section_order=$((current_section_order + 1))
      continue
    fi

    matches="$(
      printf '%s\n' "$line" \
        | grep -oE '(^|[^[:alnum:]_/-])(#|GH-)[0-9]+|/issues/[0-9]+|[[:alnum:]_.-]+/[[:alnum:]_.-]+#[0-9]+' \
        | grep -oE '(#|GH-|/issues/)[0-9]+|#[0-9]+' \
        | grep -oE '[0-9]+' || true
    )"

    if [[ -z "$matches" ]]; then
      continue
    fi

    while IFS= read -r mentioned_issue; do
      if [[ -n "$mentioned_issue" ]]; then
        printf '%s\t%s\t%s\n' "$current_section_order" "$mentioned_issue" "$current_section" >> "$sections"
      fi
    done <<< "$matches"
  done <<< "$body"
fi

: > "$tmp"
current_section=""
issue_count=0
while IFS=$'\t' read -r _section_order mentioned_issue section; do
  if [[ "$section" != "$current_section" ]]; then
    if [[ -n "$current_section" ]]; then
      :
    fi
    current_section="$section"
    if [[ -n "$current_section" ]]; then
      printf '# %s\n\n' "$current_section" >> "$tmp"
    fi
  fi

  issue_count=$((issue_count + 1))
  echo "Fetching #$mentioned_issue${current_section:+ ($current_section)}..." >&2

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
  awk -F '\t' '!seen[$1 FS $2]++ { print }' "$sections"
)

if [[ "$issue_count" -eq 0 ]]; then
  echo "Error: no issue numbers found in #$issue." >&2
  exit 1
fi

mv "$tmp" "$output"
rm -f "$sections"
trap - EXIT

echo "Wrote $issue_count issues to $output"
