---
name: write-release-notes
description: Write Dutch release notes for end users and stakeholders from the issues and pull requests of a GitHub release. Use when asked to write release notes for a release tag, e.g. "/write-release-notes v3.8.0" or "schrijf de release notes voor v3.8.0".
argument-hint: RELEASE_TAG [--issue-repo OWNER/REPO] [-R OWNER/REPO] [--previous-tag TAG]
disable-model-invocation: true
---

# Write release notes

Write Dutch release notes for release `$ARGUMENTS` from the issue dump of the
[`gh-release-changes`](https://github.com/specsnl/gh-release-changes) CLI.

## 1. Find the CLI

Run `gh-release-changes version` (the Homebrew binary) first, so a release candidate installed from
`specsnl/tap/gh-release-changes@rc` wins. If that fails, run `gh release-changes version` (the gh extension). Use
the first one that works as `<cli>` below. If neither works, stop and tell the user to install it:

```sh
gh extension install specsnl/gh-release-changes
# or, with Homebrew:
brew install specsnl/tap/gh-release-changes
```

## 2. Work out the arguments

- **Tag** (required): always pass it explicitly; without a tag the CLI wants an interactive terminal and fails.
  If `$ARGUMENTS` holds a release URL (`https://<host>/<owner>/<repo>/releases/tag/<tag>`), use its tag and pass
  `-R <owner>/<repo>` (`-R <host>/<owner>/<repo>` when the host is not `github.com`). If no tag is given, ask
  for it; `gh release list --limit 5` shows the latest releases to suggest.
- **Repository**: the GitHub repository of the current directory, unless `-R` is given.
- **`--issue-repo OWNER/REPO`**: pass it when the issue numbers in the PR titles point at another repository.
- **`--previous-tag TAG`**: pass it only when the user asks to compare with a specific tag.

## 3. Fetch the dump

Write the dump to a temporary file outside the project, so it never ends up in the repository (it holds
usernames and internal discussion):

```sh
dump="$(mktemp -t release-dump.XXXXXX)"
<cli> [-R OWNER/REPO] [--previous-tag TAG] dump <tag> [--issue-repo OWNER/REPO] > "$dump"
```

- Exit `0`: everything was read.
- Exit `4`: the dump is complete except for issues or pull requests that could not be read; they are marked
  `_Could not be read: …_`. Carry on, and list them under **Verduidelijking nodig**.
- Exit `1`: relay the `error: …` line from stderr and stop. The common causes are an unknown tag
  (`tag_not_found`), and a missing **Contents: write** permission on the repository (`forbidden`), which GitHub's
  generate-notes API requires even though it creates nothing; authentication is `gh`'s own (`gh auth login`).

Read the dump file completely before writing anything. If it says `No issues or pull requests to describe.`, tell the
user the release has nothing to write about and stop.

## 4. Write

Write the release notes following [release-notes-instructions.md](release-notes-instructions.md).

If `releasenotes.md` does not exist in the project root, create it with a `# Release notes` heading. Insert the
release notes directly below `# Release notes`, above the previous release, and leave the rest of the file
unchanged. If a section for this release already exists, ask before replacing it.

## 5. Report

Report briefly how many items were included, and list the items under **Verduidelijking nodig** in the chat (not
in `releasenotes.md`). Remove the temporary dump file.
