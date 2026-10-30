---
name: changelog
description: Write a Dutch changelog for a release from its GitHub issues and pull requests. Use when asked to create a changelog for a release tag, e.g. "/changelog v3.8.0".
argument-hint: RELEASE_TAG
---

# Changelog

Write the changelog for release `$ARGUMENTS`. If no release tag is given, ask for it.

1. In the project root, run [get-release-issues.sh](../../scripts/get-release-issues.sh) (in this plugin, relative to this skill's directory) with `$ARGUMENTS` as argument. This writes `$ARGUMENTS-issues.md`.
2. Read `$ARGUMENTS-issues.md` completely.
3. Write the changelog following [changelog-instructions.md](changelog-instructions.md).
4. If `changelog.md` does not exist in the project root, create it with a `# Changelog` heading. Insert the changelog in `changelog.md`, directly below `# Changelog` (above the previous release). Leave the rest of the file unchanged. If a section for this release already exists, ask before replacing it.
5. Report briefly how many items were included, and list the items under **Needs clarification** in the chat (not in `changelog.md`).
