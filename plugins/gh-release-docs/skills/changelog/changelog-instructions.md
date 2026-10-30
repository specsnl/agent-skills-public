# Change Log Writing Skill

## Purpose

Create a concise change log from a list of issues in Markdown.
The change log is intended for people who want a quick overview of what changed in a release without reading the individual issues.
For each relevant issue, include:

- a short, clear title;
- one or two sentences describing the change.

Group all items by product area. Use the product areas from previous releases in `changelog.md`. If there are none, propose areas based on the issues and ask the user to confirm them before writing.

---

## Input

The input is a Markdown file with:

- `## #<nr> <titel> [<status>]` — an issue, with its description, comments and related pull requests;
- `## PR #<nr> <titel> [<status>] (no issue)` — a pull request without an issue; use its description as the source.

Use the issue and pull request content as the source of truth. When an issue and its pull request differ, the pull request describes what was actually built.

Do not invent functionality or impact that is not supported by the source.

### Not (fully) released

Place an item under **Needs clarification** instead of in the change log when:

- the issue status is `[OPEN]`; or
- a related pull request has status `[OPEN]`.

The change may be only partly released. State what is known and that it must be confirmed what is actually in this release.

---

## Output format

Write the change log in **Dutch**, using this structure:

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

- **Korte duidelijke titel.** In één of twee zinnen wat er mis ging en wat er nu gebeurt.
```

Use **Backend** for functional changes that are not tied to a product area, and **Fixes** for bug fixes. Omit a section when it has no items.

Items under **Needs clarification** are not part of the change log; report them separately.

---

## Writing rules

### Title

Use:

```text
- **title.** <Short user-facing title.>
```

The title should:

- describe the actual change;
- be understandable without opening the issue;
- preferably be shorter than the original issue title;
- avoid unnecessary technical implementation details.

Keep terminology that users of the product are expected to know.

### Description

Describe the change in **one or two concise sentences**.

Focus on:

- what changed;
- what now works differently;
- what functionality was added, changed, or fixed.

Do not describe:

- implementation details unless they are essential to understand the change;
- test changes;
- refactoring;
- internal architecture;
- developer workflow;
- maintenance that has no functional effect.

---

## Categorisation

Assign every included issue to one or more product areas, based on what the issue and its pull requests describe. An issue that affects several areas is listed under each of them.

---

## Exclude

Do not include issues that only concern:

- refactoring;
- code cleanup;
- tests;
- dependency updates;
- monitoring or logging;
- CI/CD;
- developer tooling;
- infrastructure without functional impact;
- removal of unused code;
- technical preparation for future functionality where current behaviour does not change.

If an issue contains both technical work and a functional change, describe only the functional change.

---

## Unclear issues

If it is unclear whether an issue belongs in the change log or which area it affects, do not guess.

Place it at the end under:

```markdown
## Needs clarification
```

Use this format:

```markdown
- **Titel:** explain briefly what is unclear.
```

For example:

```markdown
- **Cache aanpassen:** het issue beschrijft een technische wijziging, maar niet of gebruikers hierdoor ander gedrag ervaren.
```

---

## Final checks

Before returning the change log, verify that:

- do not use issue number;
- every item has a concise title;
- every item contains no more than two sentences of explanation;
- every item is grouped under the correct product area;
- issues affecting multiple areas are repeated where appropriate;
- purely technical work is excluded;
- no behaviour or impact has been invented;
- unclear items and not (fully) released items are listed under **Needs clarification**;
- the change log is written in Dutch.
