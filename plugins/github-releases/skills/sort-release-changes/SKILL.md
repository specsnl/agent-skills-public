---
name: sort-release-changes
description: Produce the English "What's Changed" list of a GitHub release, grouped into Features, Bug fixes, Other, Maintenance and Dependencies in GitHub's format for the release description, plus the released issues per group (or a QA checklist) for the release ticket, shown in the chat only. Use when asked what is in a release, for its changes or issues, or to prepare a release description or release ticket, e.g. "what's in this release", "which issues are in the RC", "list the changes since v3.7.1", "prepare the release description", "prepare the release of the latest candidate", "make a QA checklist for the release ticket", "sort this release", "wat zit er in deze release", "welke issues zitten in de laatste RC", or a pasted `/releases/tag/<tag>` URL. The release can be named by tag or by role (latest release, latest candidate, current release). Not for creating or updating the release ticket on GitHub (create-release-ticket), Dutch release notes (write-release-notes) or a changelog (write-changelog).
argument-hint: RELEASE_TAG [--relative-to OWNER/REPO] [--scope-issue-repo OWNER/REPO] [-R OWNER/REPO] [--previous-tag TAG | --since-final] [--link closing] [--unlinked] [--tasks] [--titles]
---

# Sort release changes

Print the grouped "What's Changed" list and the issue list of the release asked for (`$ARGUMENTS`), both rendered
by the [`gh-release-changes`](https://github.com/specsnl/gh-release-changes) CLI.

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
  this skill gives the release description. Never create, edit or publish a GitHub release.
- **Repository**: the GitHub repository of the current directory, unless `-R` is given.
- **`--relative-to OWNER/REPO`**: pass it when the release ticket lives in another repository than the one
  released, so the issues are written as `OWNER/REPO#N` and link correctly from the ticket. If the user names
  the ticket's repository or links the ticket, derive it from that.
- **`--scope-issue-repo OWNER/REPO`**: pass it when the issue numbers in the PR titles point at another repository.
- **`--previous-tag TAG`**: pass it only when the user asks to compare with a specific tag.
- **`--since-final`**: compare with the newest final release older than the tag instead of GitHub's choice, so
  a later release candidate (`v3.8.0-rc.3`) covers the whole release cycle rather than only what changed since
  the previous candidate. Pass it when the user asks for it or for the whole release, or when the tag was
  resolved to a candidate as above. It excludes `--previous-tag`: never pass both.
- **`--link closing`**: also take the issues a pull request closes on GitHub (a closing keyword such as
  `Closes #13`, or a link in its Development sidebar), not only the digit scopes of its title. Pass it when the
  user asks for it, or when the pull requests reference their issues in the description rather than the title.
- **`--unlinked`**: also list the pull requests without an issue (Dependabot bumps excepted) in a
  **Pull requests without an issue** section, so nothing in the release stays invisible in the ticket.
- **`--tasks`**: write every line of the issue list as a task (`- [ ] #N`), for a release ticket QA ticks the
  issues off in. Pass it when the user asks for a checklist or tasks.
- **`--titles`**: follow every issue reference with its title (`* #N <title>`), for places that do not expand
  references, such as Zammad or mail. Pass it when the user asks for titles or pastes the list outside GitHub.
  It combines with `--tasks`.

## 3. Run

```sh
<cli> [-R OWNER/REPO] [--previous-tag TAG | --since-final] [--link closing] sort <tag>
<cli> [-R OWNER/REPO] [--previous-tag TAG | --since-final] [--link closing] issues <tag> \
  [--scope-issue-repo OWNER/REPO] [--relative-to OWNER/REPO] [--unlinked] [--tasks] [--titles]
```

To state the range, read the tag the release is compared with from `previous_tag` in the JSON of
`<cli> [-R OWNER/REPO] [--previous-tag TAG | --since-final] items <tag>`.

`--scope-issue-repo`, `--relative-to`, `--unlinked`, `--tasks` and `--titles` belong to `issues` only. Stdout is the
product; stderr carries warnings and errors. Exit `4` from `issues --titles` means a title could not be read: the
list is still complete, with a bare reference for that issue; carry on and mention the warning. If a command exits
`1`, relay its `error: …` line. The common causes are an unknown tag (`tag not found`), and a missing
**Contents: write** permission on the repository (`forbidden: …`), which GitHub's generate-notes API requires even
though it creates nothing; authentication is `gh`'s own (`gh auth login`).

## 4. Show the result

Start with the resolved tag and the tag it is compared with (`v3.8.0-rc.3, compared with v3.7.1`), so a wrong
guess is visible at once.

Show the two outputs in separate fenced `markdown` code blocks, so each can be copied on its own:

1. The output of `sort`, for the release description.
2. The output of `issues`, for the release ticket.

Put a one-line intro before each block. Show both outputs exactly as printed: do not edit, reorder, translate
or add anything inside the blocks. If an output contains a run of three or more backticks, use a longer fence.

After the blocks, mention any `warning:` lines from stderr, such as pull requests whose title is outside the
`<type>[(<scopes>)][!]: <subject>` format (they are listed under **Unclassified**), and any `info:` lines, such
as `--since-final` finding no older final release. When the tag is a later release candidate (`-rc.2` or higher) and
neither `--previous-tag` nor `--since-final` was passed, add that the lists hold only the changes since the
previous candidate, and that `--since-final` covers the whole release.
