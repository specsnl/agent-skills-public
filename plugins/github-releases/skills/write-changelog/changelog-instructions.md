# Changelog instructions

## Purpose

Write a concise changelog, in Markdown, for people who want a quick overview of what changed in a release
without reading the individual issues. For every relevant issue or pull request, give:

- a short, clear title;
- one or two sentences describing the change.

Group the items by product area. Use the product areas of earlier releases in `changelog.md`. If there are none,
propose areas based on the issues and ask the user to confirm them before writing.

## Input

The input is the output of `gh release-changes dump`: one Markdown document with a `##` heading per group
(Features, Bug fixes, Other), and under it:

- `### Issue #<nr>: <title>` — a referenced issue, with its state, labels, description, comments, the pull
  requests in this release that reference it, and the pull requests linked to it (each marked
  `In this release: yes` or `no`);
- `### Pull request #<nr>: <title>` — a feature or fix without an issue; its description is the source.

Descriptions and comments are quoted in `~~~markdown` fences; headings inside them belong to the quoted text, not
to the dump. An issue or pull request marked `* **Breaking change**` changes existing behaviour.

The issues and pull requests are the source of truth. When an issue and its pull requests differ, the pull
requests describe what was actually built. Do not invent functionality or impact the source does not support.

### Not (fully) released

Put an item under **Verduidelijking nodig** instead of in the changelog when:

- the issue's state is `open`;
- a linked pull request is `In this release: no` and its state is `open`; or
- the issue or pull request is marked `_Could not be read: …_`.

The change may be only partly released. State what is known and that it must be confirmed what is actually in
this release.

## Output format

Write the changelog in **Dutch**, with this structure:

```markdown
## Release <versie>

### <Productonderdeel>

- **Korte duidelijke titel.** In één of twee zinnen wat er is gewijzigd.
- **Andere wijziging.** In één of twee zinnen wat er is gewijzigd.

### <Ander productonderdeel>

- **Korte duidelijke titel.** In één of twee zinnen wat er is gewijzigd.

### Backend

- **Korte duidelijke titel.** In één of twee zinnen wat er is gewijzigd.

### Fixes

- **Korte duidelijke titel.** In één of twee zinnen wat er misging en wat er nu gebeurt.
```

Use **Backend** for functional changes that are not tied to a product area, and **Fixes** for bug fixes — the
dump's Bug fixes group is a good starting point, but judge each item by its content. Omit a section when it has
no items.

Items under **Verduidelijking nodig** are not part of the changelog; report them separately.

## Writing rules

### Title

Start every item with a bold title ending in a full stop: `- **Korte duidelijke titel.**`. The title:

- describes the actual change;
- is understandable without opening the issue;
- is preferably shorter than the original issue title;
- avoids unnecessary technical details.

Keep terminology that users of the product are expected to know.

### Description

Describe the change in **one or two concise sentences**: what changed, what now works differently, or what was
added, changed or fixed. Start a breaking change's description with what users must do differently.

Do not describe implementation details unless they are essential to understand the change, nor test changes,
refactoring, internal architecture, developer workflow or maintenance without functional effect.

## Categorisation

Assign every included item to one or more product areas, based on what the issue and its pull requests
describe. An item that affects several areas is listed under each of them.

## Exclude

Do not include items that only concern:

- refactoring or code cleanup;
- tests;
- dependency updates;
- monitoring or logging;
- CI/CD or developer tooling;
- infrastructure without functional impact;
- removal of unused code;
- technical preparation for future functionality where current behaviour does not change.

If an item contains both technical work and a functional change, describe only the functional change.

## Unclear items

If it is unclear whether an item belongs in the changelog, or which area it affects, do not guess. Put it under
**Verduidelijking nodig** in this format:

```markdown
- **Titel:** leg kort uit wat er onduidelijk is.
```

For example:

```markdown
- **Cache aanpassen:** het issue beschrijft een technische wijziging, maar niet of gebruikers hierdoor ander gedrag ervaren.
```

## Final check

Before returning the changelog, verify that:

- no issue or pull request numbers are present;
- every item has a concise title;
- every item has no more than two sentences of explanation;
- every item is under the correct product area, and repeated under every area it affects;
- purely technical work is excluded;
- no behaviour or impact has been invented;
- unclear and not (fully) released items are under **Verduidelijking nodig**;
- the changelog is written in Dutch.
