---
name: write-changelog
description: Write a short Dutch changelog of a GitHub release, grouped by product area, Backend and Fixes, and add it to changelog.md. Use when asked for a changelog or to add a release to changelog.md, e.g. "update the changelog for the latest candidate", "add this release to changelog.md", "/write-changelog v3.8.0", "maak de changelog voor de laatste release", "maak de changelog voor v3.8.0". The release can be named by tag, release URL or role (latest release, latest candidate, current release). Not for release notes in prose for end users (write-release-notes) or the "What's Changed" list of the release description (sort-release-changes).
argument-hint: RELEASE_TAG [--scope-issue-repo OWNER/REPO] [-R OWNER/REPO] [--previous-tag TAG | --since-final] [--link closing]
---

# Write changelog

Write a Dutch changelog for the release asked for (`$ARGUMENTS`) from the issue dump of the
[`gh-release-changes`](https://github.com/specsnl/gh-release-changes) CLI.

## 1. Find the CLI

Run `gh-release-changes version` (the Homebrew binary) first, so a release candidate installed from
`specsnl/tap/gh-release-changes@rc` wins. If that fails, run `gh release-changes version` (the gh extension). Use
the first one that works as `<cli>` below. It prints `gh-release-changes version <version>`; read it as
`v<version>`, and compare versions with the semantic versioning rules (`v0.3.0-rc.1` < `v0.3.0` < `v0.3.1`). Skip
the version checks when it is not a semantic version (a local build).

- **Missing or too old**: when neither works, or the version is older than **v0.3.0**, the minimum this skill
  needs, stop. Refer the user to the `setup-gh-release-changes` skill of this plugin (Claude:
  `/setup-gh-release-changes`, Copilot: `/github-releases:setup-gh-release-changes`), which shows how to install
  or upgrade the CLI.
- **Newer release available**: when
  `gh release view -R specsnl/gh-release-changes --json tagName -q .tagName` reports a newer version, mention it
  and refer the user to `setup-gh-release-changes` to upgrade, then continue with the task. When the lookup fails
  (offline, rate limit), skip it silently.

## 2. Work out the arguments

- **Tag** (required): always pass it explicitly; without a tag the CLI wants an interactive terminal and fails.
  Resolve it from the request (`$ARGUMENTS`, or the user's words), and pass `-R` to the `gh release` commands below
  when the repository is given:
  - **A tag or a release URL** (`https://<host>/<owner>/<repo>/releases/tag/<tag>`): use that tag. For a URL, pass
    `-R <owner>/<repo>` (`-R <host>/<owner>/<repo>` when the host is not `github.com`).
  - **"The latest release", "the last release"**: GitHub's latest release, which leaves out pre-releases:
    `gh release view --json tagName -q .tagName`.
  - **"The latest candidate", "the newest RC"**: the newest pre-release, with `--since-final`:
    `gh release list --exclude-drafts --json tagName,isPrerelease -q '[.[] | select(.isPrerelease)][0].tagName'`.
    It only counts when it is newer than the latest release (`v0.3.0-rc.1` is not, once `v0.3.1` is out): its
    final release is then already out, so there is no open candidate. Say so and ask.
  - **"The current release", "the release we're working on", "the upcoming release"**: the newest release,
    pre-releases included, with `--since-final` when it is a pre-release:
    `gh release list --exclude-drafts --limit 1 --json tagName -q '.[0].tagName'`.
  - **"The final" or "the whole release", or the candidate about to be promoted**: the final tag of that version
    when it exists, otherwise the newest candidate of that version, with `--since-final`.

  Ask only when the request names no release at all, or when the resolution is ambiguous, and suggest the tags
  from `gh release list --limit 5`. A request to create the release of a candidate means preparing its texts:
  `sort-release-changes` gives the release description. Never create, edit or publish a GitHub release.
- **Repository**: the GitHub repository of the current directory, unless `-R` is given.
- **`--scope-issue-repo OWNER/REPO`**: pass it when the issue numbers in the PR titles point at another repository.
- **`--previous-tag TAG`**: pass it only when the user asks to compare with a specific tag.
- **`--since-final`**: compare with the newest final release older than the tag instead of GitHub's choice, so
  a later release candidate (`v3.8.0-rc.3`) covers the whole release cycle rather than only what changed since
  the previous candidate. Pass it when the user asks for it or for the whole release, or when the tag was
  resolved to a candidate as above. It excludes `--previous-tag`: never pass both.
- **`--link closing`**: also take the issues a pull request closes on GitHub (a closing keyword such as
  `Closes #13`, or a link in its Development sidebar), not only the digit scopes of its title. Pass it when the
  user asks for it, or when the pull requests reference their issues in the description rather than the title.

## 3. Fetch the dump

Write the dump to a temporary file outside the project, so it never ends up in the repository (it holds
usernames and internal discussion):

```sh
dump="$(mktemp -t release-dump.XXXXXX)"
<cli> [-R OWNER/REPO] [--previous-tag TAG | --since-final] [--link closing] dump <tag> [--scope-issue-repo OWNER/REPO] > "$dump"
```

- Exit `0`: everything was read.
- Exit `4`: the dump is complete except for issues or pull requests that could not be read; they are marked
  `_Could not be read: …_`. Carry on, and list them under **Verduidelijking nodig**.
- Exit `1`: relay the `error: …` line from stderr and stop. The common causes are an unknown tag
  (`tag not found`), and a missing **Contents: write** permission on the repository (`forbidden: …`), which GitHub's
  generate-notes API requires even though it creates nothing; authentication is `gh`'s own (`gh auth login`).

Tell the user the resolved tag and the tag it is compared with, from the `Compared with:` line at the top of the
dump (`v3.8.0-rc.3, compared with v3.7.1`), so a wrong guess is visible at once. Read the dump file completely
before writing anything. If it says `No issues or pull requests to describe.`, tell the user the release has
nothing to write about and stop.

## 4. Write

Write the changelog following [changelog-instructions.md](changelog-instructions.md).

If `changelog.md` does not exist in the project root, create it with a `# Changelog` heading. Insert the
changelog directly below `# Changelog`, above the previous release, and leave the rest of the file unchanged. If
a section for this release already exists, ask before replacing it.

## 5. Report

Report briefly how many items were included, and list the items under **Verduidelijking nodig** in the chat (not
in `changelog.md`). Remove the temporary dump file.
