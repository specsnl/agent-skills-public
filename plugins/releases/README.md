# Releases plugin

Skills for writing Dutch release notes and changelogs for releases, based on the GitHub issues and
pull requests in a release.

## Installation

Claude: `claude plugin install releases@specs-public`  
Copilot: `copilot plugin install releases@specs-public`

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`), logged in with access to the repository

## How it works

1. `scripts/get-release-issues.sh` reads a GitHub release and collects every issue and pull request
   it refers to into one Markdown file (`RELEASE_TAG-issues.md`).
2. A skill reads that file and writes the release notes or changelog in Dutch.

Run the skills from within the project you are writing release notes for. The GitHub repository of
that directory is used, and the output is written there.

Items are grouped by product area. The skills use the areas from earlier releases in
`releasenotes.md` or `changelog.md`. On the first run in a project there are none; the skills then
propose areas based on the issues and ask you to confirm them.

## Skills

**releasenotes**:  
Claude: `/releasenotes v3.8.0`  
Copilot: `/releases:releasenotes v3.8.0`

Adds the release notes for `v3.8.0` to `releasenotes.md` in the project root, above the previous
release. Items whose user impact is unclear, or that are not (fully) released, are not added; they
are listed in the chat under **Verduidelijking nodig**. The writing rules are in
`skills/releasenotes/release-notes-instructions.md`.

**changelog**:  
Claude: `/changelog v3.8.0`  
Copilot: `/releases:changelog v3.8.0`

Adds the changelog for `v3.8.0` to `changelog.md` in the project root, grouped by product area,
Backend and Fixes. Unclear or not (fully) released items are listed in the chat under
**Needs clarification**. The writing rules are in `skills/changelog/changelog-instructions.md`.

## Scripts

**get-release-issues.sh**:  
Used by both skills. Picks up pull requests in the release's "What's Changed" list that:

- are titled `type(ISSUE_NUMBER): ...`, for example `feat(7807): ...`. For each issue it writes the
  description, comments and the pull requests that close it.
- are titled `feat: ...` or `fix: ...` without an issue number. These are included with their own
  description.

The result is written to `RELEASE_TAG-issues.md` in the current directory.

**get-issues.sh**:  
Fetches the issues mentioned in a single issue (or a Task issue itself), with their comments and
linked pull requests. Not used by the skills.

## Output files

The skills write `releasenotes.md`, `changelog.md` and `RELEASE_TAG-issues.md` in the project you
run them from. The `*-issues.md` files contain usernames and internal data; do not commit them. Add
them to your `.gitignore` file:

```gitignore
# Fetched issue dumps (contain usernames and internal data)
*-issues.md
```
