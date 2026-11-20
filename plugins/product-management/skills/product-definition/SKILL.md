---
name: product-definition
description: Create or update a Product Definition (vision, target groups, needs, features, business goals, differentiators) from existing product documents in a local folder.
argument-hint: "[folder with product documents]"
disable-model-invocation: true
---

# Product Definition

Help the user create or update `<product-name>-product-definition.md` in the current working directory, based on their existing product documents.

Be friendly and brief. Use the user's language. Explain what you are doing in one short line per step; never show raw tool output.

## 1. Start or update

- If one or more `*-product-definition.md` files exist, ask whether the user wants to update one of them (which one) or create a new one. When updating, use the folder from `$ARGUMENTS` if given, otherwise the source folder from its frontmatter, and confirm the folder is still correct.
- For a new definition, use the folder from the arguments: `$ARGUMENTS`. If it is empty, ask the user which folder contains their product documents (e.g. PDFs, Word, PowerPoint, Markdown).

If the folder does not exist or contains no readable files, say so and ask again.

## 2. Read the documents

Read every file in the folder, including subfolders:

- Markdown and text: read directly.
- PDF: read directly.
- Word and PowerPoint: convert to text with an available tool (such as the docx or pptx skill, `pandoc`, or `markitdown`). If none is available, ask the user to save those files as PDF in the same folder.

Tell the user which files you read, and which you skipped and why. Continue with what you could read.

## 3. Analyze

Analyze all documents together with the [product-definition-instructions](./product-definition-instructions.md).

Show the user a short summary, not the full analysis:

- per subject: found or `Not found`, with its confidence
- Completeness and Strength
- the suggestions

## 4. Fill the gaps

Confirm the product name: suggest the name found in the documents, or ask for it if none was found. When updating, use the name from the existing file and skip this question.

For each subject that is `Not found` or Low confidence, and for each contradiction, ask the user one targeted question.

- Ask one question at a time and wait for the answer before asking the next. Never list multiple questions.
- Make clear the user may skip a question or answer "I don't know".
- Before the first question, confirm the user's name: suggest the one from `git config user.name` when it is set, otherwise ask for it.
- Use the user's answers as evidence: `**Evidence:** Input from <name> (<YYYY-MM-DD>)`.
- Never fill a gap yourself; skipped subjects stay `Not found`.

## 5. Write the Product Definition

Write `<product-name>-product-definition.md` in the current working directory (product name in lowercase, spaces replaced by hyphens, e.g. `acme-product-definition.md`), following the output format of the instructions, starting with this frontmatter:

```markdown
---
source-folder: <absolute path to the source folder>
updated: <today's date, YYYY-MM-DD>
---

# Product Definition: <product name>
```

When updating, show the user what changed compared to the previous version and wait for their confirmation before overwriting it.

End with one line: where the file is, the Completeness and Strength, and that they can run `/product-definition` again whenever their documents change.
