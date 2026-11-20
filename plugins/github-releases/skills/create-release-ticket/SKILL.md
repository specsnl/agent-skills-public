---
name: create-release-ticket
description: Create or update the release ticket, the GitHub issue that tracks a release through QA and deploy, from the issues of a GitHub release and the project's ticket template, with `gh release-changes ticket`. Always shows a dry run and asks before it creates or edits the issue; a re-run for a later candidate rewrites only the generated part, so ticked boxes survive. Also sets up the template. Use when asked to create, open, update or refresh the release ticket or its template, e.g. "create the release ticket for the latest candidate", "update the release ticket for v3.8.0-rc.2", "open the PROD release issue in OWNER/tickets", "set up a release ticket template", "maak het release ticket voor de laatste RC", "werk het release ticket bij". The release can be named by tag, release URL or role (latest release, latest candidate, current release). For the issue list or QA checklist in the chat only, use sort-release-changes.
argument-hint: RELEASE_TAG [--create-in OWNER/REPO] [--var KEY=VALUE]... [--template PATH] [--title TITLE] [--label LABEL] [-R OWNER/REPO] [--dry-run] | init [--dir PATH] [--force]
---

# Create release ticket

Create or update the release ticket of the release asked for (`$ARGUMENTS`) with the `ticket` command of the
[`gh-release-changes`](https://github.com/specsnl/gh-release-changes) CLI, or set up its template with
`ticket init`. Creating or editing an issue is visible to others: never do it without the user's confirmation of
a dry run.

## 1. Find the CLI

Run `gh-release-changes version` (the Homebrew binary) first, so a release candidate installed from
`specsnl/tap/gh-release-changes@rc` wins. If that fails, run `gh release-changes version` (the gh extension). Use
the first one that works as `<cli>` below. It prints `gh-release-changes version <version>`; read it as
`v<version>`, and compare versions with the semantic versioning rules (`v0.3.0-rc.1` < `v0.3.0` < `v0.3.1`). Skip
the version check when it is not a semantic version (a local build).

- **Missing or too old**: when neither works, or `<cli> ticket --help` fails because the version has no `ticket`
  command yet, stop. Refer the user to the `setup-gh-release-changes` skill of this plugin (Claude:
  `/setup-gh-release-changes`, Copilot: `/github-releases:setup-gh-release-changes`), which shows how to install
  or upgrade the CLI.
- **Newer release available**: when
  `gh release view -R specsnl/gh-release-changes --json tagName -q .tagName` reports a newer version, mention it
  and refer the user to `setup-gh-release-changes` to upgrade, then continue with the task. When the lookup fails
  (offline, rate limit), skip it silently.

Read `<cli> ticket --help` (and `<cli> ticket init --help` before an `init`). It is the reference for the flags,
the template data and the template lookup. Where it differs from this skill, for example in the name of the flag
for the ticket repository (`--create-in` below), follow the help.

## 2. Work out the arguments

When the user asks to set up a template rather than a ticket, go to step 6.

- **Tag** (required): always pass it explicitly. Resolve it from the request (`$ARGUMENTS`, or the user's words),
  and pass `-R` to the `gh release` commands below when the repository is given:
  - **A tag or a release URL** (`https://<host>/<owner>/<repo>/releases/tag/<tag>`): use that tag. For a URL, pass
    `-R <owner>/<repo>` (`-R <host>/<owner>/<repo>` when the host is not `github.com`).
  - **"The latest release", "the last release"**: GitHub's latest release, which leaves out pre-releases:
    `gh release view --json tagName -q .tagName`.
  - **"The latest candidate", "the newest RC"**: the newest pre-release:
    `gh release list --exclude-drafts --json tagName,isPrerelease -q '[.[] | select(.isPrerelease)][0].tagName'`.
    It only counts when it is newer than the latest release (`v0.3.0-rc.1` is not, once `v0.3.1` is out): its
    final release is then already out, so there is no open candidate. Say so and ask.
  - **"The current release", "the release we're working on", "the upcoming release"**: the newest release,
    pre-releases included: `gh release list --exclude-drafts --limit 1 --json tagName -q '.[0].tagName'`.

  Ask only when the request names no release at all, or when the resolution is ambiguous, and suggest the tags
  from `gh release list --limit 5`. Never create, edit or publish a GitHub release.
- **Repository**: the GitHub repository of the current directory, unless `-R` is given.
- **`--create-in OWNER/REPO`**: the repository the ticket is created in, when the user names it or links an
  issue there. Without it the ticket goes to the source repository. Issue references follow it by default, so
  `--relative-to` is only needed to override that.
- **Range**: `ticket` covers the whole release by default (`--since-final`), so a ticket for `rc.2` still lists
  everything since the previous final release. Do not add `--since-final`; pass `--previous-tag TAG` only when the
  user asks to compare with a specific tag.
- **`--var KEY=VALUE`**: the values only the project knows, such as the target environment or a CAB number. Which
  keys the template needs is worked out in step 3. Repeat the flag for each key.
- **`--template PATH`**, **`--title TITLE`**, **`--label LABEL`**: pass them only when the user asks. Without
  them the command uses the template of the repository and the title and label defaults it sets.
- **`--link closing`**, **`--scope-issue-repo OWNER/REPO`**, **`--tasks`**, **`--titles`**, **`--full-refs`**:
  as in `sort-release-changes`; pass them only when the user asks, or when the pull requests reference their
  issues in the description rather than the title (`--link closing`).

## 3. Find the template's variables

The template runs with `missingkey=error`, so a missing `--var` fails the render. Find the keys before the first
run, so the user is asked for all of them at once.

Find the template the command will use, in its lookup order: the `--template` file; without `-R`,
`.github/release-changes/ticket.md.tmpl` in the root of the repository (`git rev-parse --show-toplevel`); otherwise
the same path on the default branch of the source repository:

```sh
gh api -H 'Accept: application/vnd.github.raw' repos/OWNER/REPO/contents/.github/release-changes/ticket.md.tmpl
```

When none exists, the built-in template is used and needs no variables. Otherwise read the template and the
`*.tmpl` parts next to it that it includes:

- `.Vars.<key>` is a **required** key.
- `index .Vars "<key>"` followed by `default` is an **optional** key.
- The leading `{{/* ... */}}` comment that `ticket init` writes holds an example command with every `--var`.

Take the values from the request. Ask for every required key without a value, in one question, with the example
values from the comment as hints. Never make up a value: a wrong environment or CAB number in a ticket is worse
than a question.

## 4. Dry run

Always run the command with `--dry-run` first. It prints the title, the labels and the body, and creates nothing:

```sh
<cli> [-R OWNER/REPO] [--previous-tag TAG] [--link closing] ticket <tag> [--create-in OWNER/REPO] \
  [--var KEY=VALUE]... [--template PATH] [--title TITLE] [--label LABEL] \
  [--scope-issue-repo OWNER/REPO] [--relative-to OWNER/REPO] [--tasks] [--titles] [--full-refs] --dry-run
```

Stdout is the product; stderr carries the template source (`template: … (local)`), warnings and errors.

- Exit `0`: show the result (step 5).
- Exit `4`: the output is complete except for something that could not be read, such as an issue title. Show the
  result and mention the warning.
- Exit `1`: relay the `error: …` line and stop, with a hint:
  - **A template error**: a missing `--var` key (ask for it and run again) or a parse error, which names the file.
  - **Tag not found**: the tag does not exist; suggest tags from `gh release list --limit 5`.
  - **More than one ticket matches**: the label and version match several open issues. Show them
    (`gh issue list -R <ticket repo> --label <label> --search "<version> in:title"`) and let the user close or
    relabel the wrong one.
  - **Forbidden**: on the source repository, GitHub's generate-notes API needs **Contents: write**; on the ticket
    repository, creating or editing issues needs **Issues: write**. Authentication is `gh`'s own
    (`gh auth login`).
  - **Interactive terminal required**: `--dry-run` or `--yes` was left out. Add `--dry-run` and run again.

## 5. Confirm, then write

Show the user:

- The resolved tag and the tag it is compared with (`v3.8.0-rc.3, compared with v3.7.1`), so a wrong guess is
  visible at once.
- The template source from stderr, so a stale or unexpected template stands out.
- Whether the run creates a new ticket or updates an existing one, with the existing ticket's URL. Take it from
  the dry run, or look it up with the `gh issue list` command above. An update only rewrites the part between
  `<!-- gh-release-changes:start -->` and `<!-- gh-release-changes:end -->`; ticked boxes and answers outside it
  stay.
- The title and labels, and the body in a fenced `markdown` code block, exactly as printed. If the body contains
  a run of three or more backticks, use a longer fence.

When the user asked only for a preview, stop here. Otherwise ask whether to create (or update) the ticket. Only
after a clear yes, run the same command with `--yes` instead of `--dry-run`. When anything changes after the
dry run, such as a `--var` value or the tag, run the dry run again and ask again. Never pass `--yes` without that
confirmation, even when the user asked to create the ticket in their first message.

Report the URL of the created or updated ticket. Adding it to a project board stays manual; mention that when
the template or the user refers to one.

## 6. Set up a template

To set up a release ticket template, run:

```sh
<cli> ticket init [--dir PATH]
```

It writes `ticket.md.tmpl` and `checklist.md.tmpl` (a part the first one includes) to `.github/release-changes/`
in the repository root, from any directory inside the repository. Pass `--dir PATH` when the user wants them
elsewhere. To show the starter template without writing it, use `--stdout`.

- **The files exist** (an error naming the file): show the existing file and ask before running again with
  `--force`, which overwrites it. Never pass `--force` without that confirmation.
- **No repository root** (outside a repository): ask where to write the files and pass `--dir`.

After `init`, list the files written and the example command in the leading `{{/* ... */}}` comment of
`ticket.md.tmpl`. Suggest adapting the checklist to the project, and trying the template with a dry run (step 4)
before committing it: an uncommitted local template is used when `-R` is not given.
