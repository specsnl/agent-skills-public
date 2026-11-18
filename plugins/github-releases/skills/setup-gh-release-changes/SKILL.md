---
name: setup-gh-release-changes
description: Install or upgrade the gh-release-changes CLI that the github-releases skills run on. Checks what is installed and how, compares it with the latest release, and shows the one install or upgrade command that fits; it never installs anything itself. Use when another github-releases skill reports the CLI as missing or outdated, or when asked to install, set up, update or upgrade gh-release-changes, e.g. "/setup-gh-release-changes", "is gh-release-changes up to date?", "installeer gh-release-changes".
---

# Set up gh-release-changes

Show how to install or upgrade the [`gh-release-changes`](https://github.com/specsnl/gh-release-changes) CLI.
Only suggest commands: never install, upgrade or uninstall anything yourself.

## 1. Check what is installed

Run each check and note the result; a failing command just means that part is missing.

- **GitHub CLI**: `gh --version`.
- **Homebrew binary**: `gh-release-changes version`. When it works, find the formula it came from with
  `brew list --versions specsnl/tap/gh-release-changes` (stable) and
  `brew list --versions specsnl/tap/gh-release-changes@rc` (release candidate). When neither formula is
  installed, the binary was installed by hand.
- **gh extension**: `gh release-changes version` (only when `gh` is installed).

The version commands print `gh-release-changes version <version>`, e.g. `0.3.1` or `0.4.0-rc.1`. Read it as
`v<version>`. When it is not a semantic version (a local build), report it and skip the comparisons for it.

The other skills run the Homebrew binary when both are installed, so a release candidate wins over the stable gh
extension. Call that one the **active** install.

## 2. Find the latest release

```sh
gh release view -R specsnl/gh-release-changes --json tagName -q .tagName
```

This is the latest stable release; pre-releases are left out. When `gh` is missing or the lookup fails (offline,
rate limit), say that the latest version could not be checked, and continue without the comparisons.

Compare versions with the semantic versioning rules, pre-releases included: a pre-release is older than its own
final release (`v0.4.0-rc.1` < `v0.4.0`), but newer than any older final release (`v0.4.0-rc.1` > `v0.3.1`).

## 3. Not installed: show how to install

- **`gh` is installed** (the normal case): show only the gh extension:

  ```sh
  gh extension install specsnl/gh-release-changes
  ```

- **`gh` is not installed**: recommend installing the [GitHub CLI](https://cli.github.com/) first and logging in
  (`gh auth login`), then the gh extension above. The skills use `gh` for more than the extension anyway, such
  as `gh release list` to suggest a tag.

Mention the Homebrew binary only as an alternative, for two cases:

- To run `gh-release-changes` on its own, outside `gh`: `brew install specsnl/tap/gh-release-changes`.
- To test a release candidate: `brew install specsnl/tap/gh-release-changes@rc`.

## 4. Installed: check for an upgrade

Compare every install found with the latest release. An install is up to date when it is the latest release or
newer, so a release candidate of a coming version (`v0.4.0-rc.1` while `v0.3.1` is the latest) is up to date.

For every outdated install, show the upgrade command for how it was installed:

| Installed as      | Upgrade command                                  |
|-------------------|--------------------------------------------------|
| gh extension      | `gh extension upgrade release-changes`           |
| Homebrew (stable) | `brew upgrade specsnl/tap/gh-release-changes`    |
| Homebrew (rc)     | `brew upgrade specsnl/tap/gh-release-changes@rc` |

For a binary installed by hand, point to the
[releases page](https://github.com/specsnl/gh-release-changes/releases) to download the latest version.

Two cases need more than the command:

- **An outdated release candidate** (`v0.3.0-rc.1` while `v0.3.1` is out): its final release is already out.
  Suggest upgrading the rc formula, or switching back to the stable gh extension:
  `brew uninstall specsnl/tap/gh-release-changes@rc`, then install the gh extension when it is missing.
- **Both installed**: the Homebrew binary is the active install. When it is older than the gh extension, say so:
  the outdated Homebrew binary hides the newer extension. Suggest upgrading the Homebrew formula, or uninstalling
  it when it is not needed for standalone use or a release candidate.

## 5. Report

Report in a few lines:

- What is installed, how, and which version, marking the active install.
- The latest release, or that it could not be checked.
- The commands to run, if any, or that everything is up to date.

When another skill sent the user here, tell them to run that skill again once the commands have been run.
