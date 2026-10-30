---
name: releasenotes
description: Write Dutch release notes for a release from its GitHub issues and pull requests. Use when asked to create release notes for a release tag, e.g. "/releasenotes v3.8.0".
argument-hint: RELEASE_TAG
---

# Release notes

Write release notes for release `$ARGUMENTS`. If no release tag is given, ask for it.

1. In the project root, run [get-release-issues.sh](../../scripts/get-release-issues.sh) (in this plugin, relative to this skill's directory) with `$ARGUMENTS` as argument. This writes `$ARGUMENTS-issues.md`.
2. Read `$ARGUMENTS-issues.md` completely.
3. Write the release notes following [release-notes-instructions.md](release-notes-instructions.md).
4. If `releasenotes.md` does not exist in the project root, create it with a `# Release notes` heading. Insert the release notes in `releasenotes.md`, directly below `# Release notes` (above the previous release). Leave the rest of the file unchanged. If `## $ARGUMENTS` already exists, ask before replacing it.
5. Report briefly how many items were included, and list the items under **Verduidelijking nodig** in the chat (not in `releasenotes.md`).
