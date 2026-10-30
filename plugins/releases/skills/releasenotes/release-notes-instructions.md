# Release Notes Writing Skill

## Purpose

Create release notes for **end users and product stakeholders** in markdown format.

Release notes should explain **what changed for users**, not how the change was implemented internally.

## Output template

Write the release notes in **Dutch**, using this structure:

```markdown
## <versie>

### <Wat de gebruiker nu kan doen>

**Samenvatting:** ...

**Onderdeel:** ...

**Wat je nu kan doen:** ...
s
**Start:** ...

### Overige verbeteringen en bugfixes

#### <Productonderdeel>

- **Verbetering:** ...
- **Fixed:** ...

#### <Ander productonderdeel>

- **Fixed:** ...
```

Group the other improvements and bug fixes by product area. Use the product areas from previous releases in `releasenotes.md`. If there are none, propose areas based on the issues and ask the user to confirm them before writing. Omit a section or area when it has no items.

Items under **Verduidelijking nodig** are not part of the release notes; report them separately.

## Input

The input is a Markdown file with:

- `## #<nr> <titel> [<status>]` — an issue, with its description, comments and related pull requests;
- `## PR #<nr> <titel> [<status>] (no issue)` — a pull request without an issue; use its description as the source.

When an issue and its pull request differ, the pull request describes what was actually built.

### Not (fully) released

Place an item under **Verduidelijking nodig** instead of in the release notes when:

- the issue status is `[OPEN]`; or
- a related pull request has status `[OPEN]`.

The change may be only partly released. State what is known and that it must be confirmed what is actually in this release.

## Writing style

- Write in Dutch.
- Write in clear, concise language.
- Use non-technical terminology wherever possible.
- Focus on user-visible behaviour and outcomes.
- Prefer concrete descriptions over generic claims such as "improved experience", "better performance", or "more flexibility".
- Write so that each item can be understood without knowing the underlying issue, ticket, or implementation.
- Do not exaggerate the importance or impact of a change.
- Do not infer or invent user impact that is not supported by the source material.

---

## 1. New or changed functionality

Use this section only for changes that introduce, remove, or meaningfully change something a user can see or do.

Do **not** use the internal feature name as the heading.

Instead, describe the new capability or changed behaviour from the user's perspective.

### Format

### [Describe what the user can now do]

**Samenvatting:**
One standalone sentence explaining what changed and who it affects.

The summary should:

- make sense without additional context;
- contain the main user-visible change;
- be suitable for scanners, summaries, and AI agents quoting the release notes.

**Onderdeel:**
Specify one or more affected product areas (the same areas used for grouping). Only include areas that are actually affected.

**Wat je nu kan doen:**
Explain the capability in 2–3 sentences from the user's perspective.

Describe:

- what the user can now do;
- what problem or use case it addresses;
- when the user would use it.

Do not describe technical implementation details unless they are necessary for the user to understand or use the functionality.

Where relevant, link to the documentation instead of reproducing detailed instructions in the release notes.

**Start:**
Give the clearest first step the user should take.

Prefer a direct action, for example:

> Open **Instellingen** and select **Profiel wijzigen**.

When documentation exists, link to the relevant manual page.

Omit this field when no user action is required.

**Uit scope:**
Mention only limitations that are relevant to users.

Where known, include:

- what is not supported yet;
- a practical workaround;
- or when the limitation is expected to be resolved.

Do not invent a workaround or timeline.

Omit this field when there are no known user-relevant limitations.

---

## 2. Other improvements and bug fixes

Use this section for smaller user-visible changes that do not require a full release-note entry.

Use one of the following formats:

- **Verbetering:** [What changed] — [how this affects the user]
- **Fixed:** [What the user experienced before] → [what happens now]

Examples:

- **Verbetering:** Zoekresultaten worden efficiënter geladen — pagina's met resultaten reageren sneller bij het bladeren door grote collecties.
- **Fixed:** Afbeeldingen werden soms in de verkeerde volgorde getoond → afbeeldingen worden nu in de ingestelde volgorde getoond.

Keep each item to one concise sentence where possible.

---

## 3. Exclude from release notes

Do not include:

- maintenance work with no meaningful user-visible impact;
- refactoring or internal code changes;
- infrastructure changes that do not affect user behaviour;
- dependency or library updates unless they create a relevant user-visible change;
- monitoring, logging, test, deployment, or development-process changes;
- internal issue or ticket numbers;
- internal feature names when they are not meaningful to users;
- organisation-specific names, data, configurations, examples, or circumstances;
- implementation details that do not help users understand the change.

Never turn an internal technical change into a supposed user benefit unless that impact is explicitly supported by the source material.

---

## 4. Handling unclear issues

If it is unclear whether a change is user-visible, do not guess.

Place the item under:

## Verduidelijking nodig

For each unclear item, state briefly:

- what is known from the issue;
- what is unclear;
- what information is needed to determine whether or how it belongs in the release notes.

Example:

- **Cache aanpassen:** Het issue wijzigt het cachegedrag, maar vermeldt niet of gebruikers verschil merken in laadtijden of gedrag. Bevestig de zichtbare impact voordat het wordt opgenomen.

Do not include unclear items in the final release notes until their user impact is established.

---

## 5. Interpretation rules

When reviewing an issue, determine in this order:

1. **Is there a user-visible change?**

   - If no: exclude it.
   - If unclear: flag it under **Verduidelijking nodig**.

2. **Is it a meaningful new or changed capability?**

   - If yes: use **New or changed functionality**.
   - If no: consider **Other improvements and bug fixes**.

3. **What does the source explicitly support?**

   - Use only information present in or directly supported by the issue.
   - Do not infer benefits, affected users, limitations, or behaviour.

4. **Can the wording be understood without the issue context?**

   - Rewrite internal terminology into user-facing language.
   - Preserve product-specific terms only when users themselves encounter those terms in the interface or documentation.

---

## 6. Final quality check

Before returning the release notes, verify that:

- every included item has a user-visible impact;
- no internal issue numbers are present;
- no organisation-specific information is present;
- no unsupported impact has been invented;
- technical terminology has been removed where possible;
- headings describe user capabilities rather than implementation names;
- summaries are understandable as standalone sentences;
- bug fixes clearly describe the before-and-after behaviour;
- unclear items and not (fully) released items are listed under **Verduidelijking nodig** instead of being guessed;
- the release notes are written in Dutch.
