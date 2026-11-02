# GitHub releases plugin

Skills that turn the changes of a GitHub release into texts for different audiences: a grouped "What's Changed"
list and an issue list for developers and the release ticket, and Dutch release notes and a changelog for end
users and stakeholders.

All skills are backed by the [`gh-release-changes`](https://github.com/specsnl/gh-release-changes) CLI, which
reads GitHub's generated notes for the release. The plugin ships no scripts and handles no tokens: authentication
is `gh`'s own.

## Installation

Claude: `claude plugin install github-releases@specs-public`  
Copilot: `copilot plugin install github-releases@specs-public`

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`), logged in (`gh auth login`, or `GH_TOKEN`).
- The `gh-release-changes` CLI, as a gh extension:

  ```sh
  gh extension install specsnl/gh-release-changes
  ```

  Or with Homebrew, as a standalone `gh-release-changes` binary: `brew install specsnl/tap/gh-release-changes`.
  To try a release candidate, install `specsnl/tap/gh-release-changes@rc` instead. The skills accept either and
  prefer the Homebrew binary when both are installed, so a release candidate takes precedence over the stable gh
  extension. They print these install instructions when neither is found.
- **Contents: write** permission on the repository: GitHub's generate-notes API requires it, even though nothing
  is created.

Run the skills from **within the project** of the release, or pass `-R OWNER/REPO`. Always give the tag (or the
release URL): the CLI only offers a tag picker in an interactive terminal.

## Skills

| Skill                  | Claude                  | Copilot                                 | Purpose                               |
|------------------------|-------------------------|-----------------------------------------|---------------------------------------|
| `write-release-notes`  | `/write-release-notes`  | `/github-releases:write-release-notes`  | Dutch release notes for end users     |
| `write-changelog`      | `/write-changelog`      | `/github-releases:write-changelog`      | Dutch changelog                       |
| `sort-release-changes` | `/sort-release-changes` | `/github-releases:sort-release-changes` | Grouped "What's Changed" + issue list |

### write-release-notes

Claude: `/write-release-notes RELEASE_TAG`  
Copilot: `/github-releases:write-release-notes RELEASE_TAG`

Runs `gh release-changes dump RELEASE_TAG` and adds Dutch release notes for the release to `releasenotes.md` in
the project root, above the previous release. Items whose user impact is unclear, or that are not (fully)
released, are not added; they are listed in the chat under **Verduidelijking nodig**. The writing rules are in
`skills/write-release-notes/release-notes-instructions.md`.

### write-changelog

Claude: `/write-changelog RELEASE_TAG`  
Copilot: `/github-releases:write-changelog RELEASE_TAG`

Runs `gh release-changes dump RELEASE_TAG` and adds a Dutch changelog for the release to `changelog.md` in the
project root, grouped by product area, Backend and Fixes. Unclear or not (fully) released items are listed in the
chat under **Verduidelijking nodig**. The writing rules are in `skills/write-changelog/changelog-instructions.md`.

Both writing skills group items by product area, using the areas of earlier releases in `releasenotes.md` or
`changelog.md`. On the first run in a project there are none; the skills then propose areas based on the issues
and ask you to confirm them. The issue dump is written to a temporary file outside the project and removed
afterwards, so the usernames and internal discussion in it never end up in the repository. Pass
`--scope-issue-repo OWNER/REPO` when the issue numbers in the PR titles point at another repository.

### sort-release-changes

Claude: `/sort-release-changes RELEASE_TAG [--relative-to OWNER/REPO]`  
Copilot: `/github-releases:sort-release-changes RELEASE_TAG [--relative-to OWNER/REPO]`

Runs `gh release-changes sort` and `gh release-changes issues`, and shows both outputs unchanged in separate code
blocks:

1. The "What's Changed" list grouped into Features, Bug fixes, Other, Maintenance and Dependencies, for the
   release description.
2. The issues per group, for the release ticket.

Pass `--relative-to OWNER/REPO` when the release ticket lives in another repository, so the issues are written as
`OWNER/REPO#N`.
