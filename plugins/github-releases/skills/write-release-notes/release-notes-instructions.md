# Release notes instructions

## Purpose

Write release notes for **end users and product stakeholders**, in Markdown. Release notes explain **what
changed for users**, not how the change was implemented.

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
requests describe what was actually built. The dump's group is a hint, not a verdict: a `fix` can be a
user-visible improvement and a `feat` can have no user impact at all.

### Not (fully) released

Put an item under **Verduidelijking nodig** instead of in the release notes when:

- the issue's state is `open`;
- a linked pull request is `In this release: no` and its state is `open`; or
- the issue or pull request is marked `_Could not be read: …_`.

The change may be only partly released. State what is known and that it must be confirmed what is actually in
this release.

## Output template

Write the release notes in **Dutch**, with this structure:

```markdown
## <versie>

### <Wat de gebruiker nu kan doen>

**Samenvatting:** …

**Onderdeel:** …

**Wat je nu kan doen:** …

**Start:** …

**Uit scope:** …

### Overige verbeteringen en bugfixes

#### <Productonderdeel>

- **Verbetering:** …
- **Fixed:** …

#### <Ander productonderdeel>

- **Fixed:** …
```

Group the other improvements and bug fixes by product area. Use the product areas of earlier releases in
`releasenotes.md`. If there are none, propose areas based on the issues and ask the user to confirm them before
writing. Omit a section, area or field when it has no content.

Items under **Verduidelijking nodig** are not part of the release notes; report them separately.

## Writing style

- Write in clear, concise Dutch.
- Use non-technical terminology wherever possible.
- Focus on user-visible behaviour and outcomes.
- Prefer concrete descriptions over generic claims such as "improved experience", "better performance" or "more
  flexibility".
- Write every item so it can be understood without knowing the underlying issue or implementation.
- Do not exaggerate the importance or impact of a change.
- Do not infer or invent user impact that the source does not support.

## 1. New or changed functionality

Use this section only for changes that introduce, remove or meaningfully change something users can see or do.

Do **not** use the internal feature name as the heading. Describe the new capability or changed behaviour from
the user's perspective instead.

### [What the user can now do]

**Samenvatting:** one standalone sentence that says what changed and who it affects. It must make sense without
context and contain the main user-visible change, so it can be quoted on its own by readers, summaries and AI
agents.

**Onderdeel:** one or more affected product areas, the same areas used for grouping. Only include areas that are
actually affected.

**Wat je nu kan doen:** two or three sentences, from the user's perspective, on what the user can now do, which
problem or use case it addresses, and when they would use it. Leave out technical details unless the user needs
them to understand or use the functionality. Where documentation exists, link to it instead of reproducing
detailed instructions.

**Start:** the clearest first step for the user, preferably a direct action, for example:

> Open **Instellingen** en kies **Profiel wijzigen**.

Link to the relevant manual page when there is one. Omit this field when no user action is required.

**Uit scope:** only limitations that are relevant to users: what is not supported yet, a practical workaround,
or when the limitation is expected to be resolved — where known. Do not invent a workaround or timeline. Omit
this field when there are no known user-relevant limitations.

A breaking change with user impact always gets a full entry in this section, and says what users must do
differently.

## 2. Other improvements and bug fixes

Use this section for smaller user-visible changes that do not need a full entry, in one of these formats:

- **Verbetering:** [what changed] — [how this affects the user]
- **Fixed:** [what the user experienced before] → [what happens now]

For example:

- **Verbetering:** Zoekresultaten worden efficiënter geladen — pagina's met resultaten reageren sneller bij het
  bladeren door grote collecties.
- **Fixed:** Afbeeldingen werden soms in de verkeerde volgorde getoond → afbeeldingen worden nu in de ingestelde
  volgorde getoond.

Keep each item to one concise sentence where possible.

## 3. Exclude

Do not include:

- maintenance work, refactoring or internal code changes without meaningful user-visible impact;
- infrastructure changes that do not affect user behaviour;
- dependency or library updates, unless they create a relevant user-visible change;
- monitoring, logging, test, deployment or development-process changes;
- issue, ticket or pull request numbers;
- internal feature names that mean nothing to users;
- organisation-specific names, data, configurations, examples or circumstances;
- implementation details that do not help users understand the change.

Never turn an internal technical change into a supposed user benefit unless the source explicitly supports that
impact. If an item contains both technical work and a user-visible change, describe only the user-visible change.

## 4. Unclear items

If it is unclear whether a change is user-visible, do not guess. Put the item under **Verduidelijking nodig**,
and state briefly what is known, what is unclear, and what information is needed to decide whether or how it
belongs in the release notes. For example:

- **Cache aanpassen:** het issue wijzigt het cachegedrag, maar vermeldt niet of gebruikers verschil merken in
  laadtijden of gedrag. Bevestig de zichtbare impact voordat het wordt opgenomen.

## 5. Interpretation

For every issue and pull request, decide in this order:

1. **Is there a user-visible change?** If not, exclude it. If unclear, put it under **Verduidelijking nodig**.
2. **Is it a meaningful new or changed capability?** If so, use section 1; otherwise section 2.
3. **What does the source explicitly support?** Use only information in, or directly supported by, the issue and
   its pull requests. Do not infer benefits, affected users, limitations or behaviour.
4. **Can the wording be understood without the issue?** Rewrite internal terminology into user-facing language.
   Keep product-specific terms only when users encounter them in the interface or documentation.

## 6. Final check

Before returning the release notes, verify that:

- every included item has a user-visible impact;
- no issue, ticket or pull request numbers are present;
- no organisation-specific information is present;
- no unsupported impact has been invented;
- technical terminology has been removed where possible;
- headings describe user capabilities rather than implementation names;
- summaries are understandable as standalone sentences;
- bug fixes clearly describe the behaviour before and after;
- user-facing breaking changes say what users must do differently;
- unclear and not (fully) released items are under **Verduidelijking nodig** instead of being guessed;
- the release notes are written in Dutch.
