---
name: drift-detection
description: Derive the Observed Product Definition from the work completed over the last number of months and compare it with the current Product Definition to detect drift.
argument-hint: "[number of months]"
disable-model-invocation: true
---

# Drift Detection

Discover the product your backlog is actually building.

The work that has already been completed reveals the product vision that has actually been executed. Drift Detection derives an **Observed Product Definition** from the work delivered over a period and compares it with the current Product Definition.

Be friendly and brief. Use the user's language. Explain what you are doing in one short line per step; never show raw tool output.

## 1. Start

The skill analyzes the GitHub repository of the current working directory. If the current working directory is not inside a GitHub repository, tell the user to run the skill from one and stop.

Use `$ARGUMENTS` as the number of months. If it is empty or not a whole number, ask: "How many months of completed work should I analyze?"

The period runs from `<start>` (today minus the number of months) to `<end>` (today), both as `YYYY-MM-DD`.
Confirm the repository (`owner/repo`) and the period with the user before continuing.

Look for `*-product-definition.md` in the current working directory. If there are several, ask which one to compare with. If there is none, tell the user you will only derive the Observed Product Definition, and that they can run `/product-definition` first to also detect drift.

## 2. Get the issues

Get the completed features and user stories of the period:

```bash
gh issue list --state closed \
  --search 'closed:<start>..<end> reason:completed type:Feature,"User Story"' \
  --limit 1000 \
  --json number,title,issueType,closedAt,url,body \
  --jq '.[] | "---\n\n# #\(.number) \(.title)\n\n- Type: \(.issueType.name // "None")\n- Closed: \(.closedAt[:10])\n- URL: \(.url)\n\n\(.body // "")\n"'
```

Write the output to `issues-<start>-to-<end>.md` in the current working directory, overwriting any earlier file for the same period. Tell the user how many issues you found, and that the file stays in the working directory, where git shows it as untracked; they can keep or delete it.

- **No issues**: the repository may not use the issue types `Feature` and `User Story`. Ask whether to filter on labels instead (and which) or to analyze all completed issues, and run the command again without `type:`, with `label:<label>` if given.
- **Exactly 1000 issues**: GitHub search returns at most 1000 results, so the list is probably truncated. Tell the user and ask for a shorter period.

## 3. Derive the Observed Product Definition

Analyze all issues together with the [product-definition-instructions](../product-definition/product-definition-instructions.md), treating the issues as the source documents. When the file is large, read it in parts rather than all at once. Cite issues as evidence by number, e.g. `**Evidence:** #42, #57`.

Show the user a short summary, not the full analysis:

- per subject: found or `Not found`, with its confidence
- Completeness and Strength

## 4. Detect drift

Skip this step when there is no Product Definition.

Compare the Observed Product Definition with the current Product Definition with the [drift-detection-compare-instructions](./drift-detection-compare-instructions.md) and show the result. When there is almost no overlap, report that as the main finding: the product being built differs strongly from the defined product.

## 5. Next step

Ask whether the user wants to apply suggestions to the Product Definition, to analyze another period, or to stop.

To apply suggestions, ask which ones. Only suggestions that update the Product Definition apply; those that steer the backlog do not change it. For each chosen suggestion:

- Update only the affected subject in the Product Definition, following the [product-definition-instructions](../product-definition/product-definition-instructions.md), with the issues as evidence, e.g. `**Evidence:** #42, #57`.
- Set `updated` in the frontmatter to today's date.
- Show the user what changed and wait for their confirmation before overwriting the file.

When there is no Product Definition yet, point the user to `/product-definition` to create one.
