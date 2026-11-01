# Plan: github-releases plugin + gh-release-changes CLI

Working state of the design discussion (2026-11-01). The work is built from scratch; the existing branch and
issue below are source material only and are not updated.

## Source material

- PR #9 (`releases` branch): a plugin with `/releasenotes` and `/changelog` skills that write Dutch release
  notes and a changelog, backed by `scripts/get-release-issues.sh`. Reuse its writing instructions
  (`release-notes-instructions.md`, `changelog-instructions.md`) and the issue-dump behaviour of the script.
- Issue #7: a personal `github-minvws-release-sorter` skill (Python, hardcoded PAT) that groups a release's
  "What's Changed" list and prints the issue numbers per group. Reuse its grouping and sorting rules.

## Problem

After tagging a release, the same set of changes is written up for several audiences:

| Artifact                      | Audience                 | Nature                                 |
|-------------------------------|--------------------------|----------------------------------------|
| Grouped "What's Changed"      | developers / ops         | Deterministic: classify and sort       |
| Issue list for release ticket | PO / QA / acceptance     | Deterministic: extract and deduplicate |
| Dutch changelog               | quick overview           | Judgement: summarise and filter (LLM)  |
| Dutch release notes           | end users / stakeholders | Judgement: translate user impact (LLM) |

All four come from one source. The design is one extraction step with renderers per audience; the LLM is
used only for the prose.

## Facts about the current process

- A tag is created and GitHub's "auto generate release notes" fills the release body. That generated body
  is the base; versions for other target groups are derived from it.
- PR titles are enforced with `amannn/action-semantic-pull-request@v6`, with scopes `e2e` and `\d{4}`
  (issue number). Multiple scopes are comma-separated (`feat(6768,6747):`).
- The release ticket is a GitHub issue, possibly in a different repo. It is created by hand for now;
  automating it is a likely next step.
- Release notes are written for final tags, but it must also work for RC and patch/fix tags.

## Decisions

- **Source of truth:** the `generate-notes` API, never the (editable) release body:
  `POST /repos/{owner}/{repo}/releases/generate-notes` with `tag_name` and optional `previous_tag_name`.
- **Tooling:** a dedicated Go CLI in its own repo, **`specsnl/gh-release-changes`**, built as a gh extension
  (`gh release-changes ...`) and released with goreleaser. The plugin ships no scripts of its own. No token
  handling: auth via `go-gh` (gh auth, `GH_TOKEN`, GHES hosts).
- **Plugin name:** `github-releases` (the `gh-` prefix belongs to the CLI repo, not the plugin).
- **Skill names (verb-object):**

  | Skill                  | Claude                  | Copilot                                 | Purpose                               |
  |------------------------|-------------------------|-----------------------------------------|---------------------------------------|
  | `write-release-notes`  | `/write-release-notes`  | `/github-releases:write-release-notes`  | Dutch release notes for end users     |
  | `write-changelog`      | `/write-changelog`      | `/github-releases:write-changelog`      | Dutch changelog                       |
  | `sort-release-changes` | `/sort-release-changes` | `/github-releases:sort-release-changes` | Grouped "What's Changed" + issue list |

- **Issue list format:** plain list per group. `#N` by default; `owner/repo#N` when the ticket repo
  (`--ticket-repo`) differs from the source repo.
- **Range:** any tag (RC, patch or final) as target; `--previous-tag` overrides GitHub's choice of base.

## CLI design (`gh-release-changes`)

Common flags: `-R owner/repo` (default: repo of the current directory), `--previous-tag`.

| Command  | Output                                                                  | Used by                                  |
|----------|-------------------------------------------------------------------------|------------------------------------------|
| `items`  | JSON: PR number, title, type, scopes, issue numbers, author, URL, group | skills, automation (contract)            |
| `sort`   | Grouped "What's Changed" markdown                                       | `sort-release-changes`                   |
| `issues` | Plain issue list per group (`--ticket-repo`)                            | `sort-release-changes`                   |
| `dump`   | Issue details, comments and linked PRs for the LLM                      | `write-release-notes`, `write-changelog` |
| `ticket` | (later) create/update the release issue in the ticket repo              | automation                               |

Parser rules (strict, matching the PR-title action):

- Line format: `* <title> by @<author> in <pr-url>`; ignore headings, "New Contributors" and the
  "Full Changelog" line.
- Types: the action defaults (`feat fix docs style refactor perf test build ci chore revert`).
- Groups and order: Features (`feat`), Bug fixes (`fix`), Other (`docs test ci refactor perf style build`,
  `revert`), Maintenance (`chore`), Dependencies (`(deps)`/`(deps-dev)` scope or dependabot author).
- Issue numbers: digit scopes only (`\d+`; `e2e` and other scopes ignored), comma-separated.
  No `+`/`&`/`and` separators and no keyword fallback for titles without a type.
- Sorting: by first issue number, then PR number (no issue → bottom); Dependencies by PR number.
  Issue list: per group ascending, deduplicated.
- `dump`: every referenced issue (with comments and `closedByPullRequestsReferences`), plus `feat`/`fix`
  PRs without an issue, in one Markdown document.

Distribution: goreleaser assets named per gh's precompiled-extension convention
(`gh-release-changes-<os>-<arch>`); optionally also publish to `specsnl/homebrew-tap`.

## Plugin design (this repo)

A new plugin `plugins/github-releases`:

- `plugin.json`, `.claude-plugin/marketplace.json` entry and root `README.md` table row, all with the same
  description covering both sorting and writing.
- `skills/write-release-notes/` and `skills/write-changelog/`: run `gh release-changes dump <tag>`, then
  write the Dutch text following their instruction files (based on the PR #9 instructions, cleaned up).
- `skills/sort-release-changes/`: run `gh release-changes sort` and `issues`, and show both blocks
  unchanged in separate code fences.
- Every skill checks that the extension is installed and prints install instructions if not.
- `README.md`: Claude and Copilot install commands and invocations for every skill; requirements `gh` +
  `gh extension install specsnl/gh-release-changes`.

## Open points / to verify

- Which previous tag `generate-notes` picks by default for RC tags (e.g. final `v3.7.0` after `v3.7.0-rc.3`).
- Permissions `generate-notes` needs (likely repository contents: write). Matters for read-only users and
  a future CI token.
- Whether a `.github/release.yml` exists in the target repos (it changes the generated body's headings).
- The `\d{4}` scope rule in the PR-title action will reject issue #10000; consider `\d+`.
- CLI repo setup: module path, CI (lint/test), goreleaser config, gh-extension asset naming, Homebrew tap.
- Order of work: CLI v0.1 (`items`, `sort`, `issues`) → CLI `dump` → plugin with all three skills.
