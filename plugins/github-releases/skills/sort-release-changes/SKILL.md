---
name: sort-release-changes
description: Sort the changes of a GitHub release into a grouped "What's Changed" list (Features, Bug fixes, Other, Maintenance, Dependencies) and a list of the released issues per group, for the release description and the release ticket. Use when asked to sort, group or organise a release's changes or to list the issues of a release, e.g. "/sort-release-changes v3.8.0", "sort this release", "geef me de issues van deze release", or when a `/releases/tag/<tag>` URL is pasted.
argument-hint: RELEASE_TAG [--relative-to OWNER/REPO] [--scope-issue-repo OWNER/REPO] [-R OWNER/REPO] [--previous-tag TAG | --since-final] [--link closing] [--unlinked] [--tasks] [--titles]
disable-model-invocation: true
---

# Sort release changes

Print the grouped "What's Changed" list and the issue list of release `$ARGUMENTS`, both rendered by the
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
- **`--relative-to OWNER/REPO`**: pass it when the release ticket lives in another repository than the one
  released, so the issues are written as `OWNER/REPO#N` and link correctly from the ticket. If the user names
  the ticket's repository or links the ticket, derive it from that.
- **`--scope-issue-repo OWNER/REPO`**: pass it when the issue numbers in the PR titles point at another repository.
- **`--previous-tag TAG`**: pass it only when the user asks to compare with a specific tag.
- **`--since-final`**: compare with the newest final release older than the tag instead of GitHub's choice, so
  a later release candidate (`v3.8.0-rc.3`) covers the whole release cycle rather than only what changed since
  the previous candidate. Pass it when the user asks for it or for the whole release. It excludes
  `--previous-tag`: never pass both.
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

`--scope-issue-repo`, `--relative-to`, `--unlinked`, `--tasks` and `--titles` belong to `issues` only. Stdout is the
product; stderr carries warnings and errors. Exit `4` from `issues --titles` means a title could not be read: the
list is still complete, with a bare reference for that issue; carry on and mention the warning. If a command exits
`1`, relay its `error: …` line. The common causes are an unknown tag (`tag not found`), and a missing
**Contents: write** permission on the repository (`forbidden: …`), which GitHub's generate-notes API requires even
though it creates nothing; authentication is `gh`'s own (`gh auth login`).

## 4. Show the result

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
