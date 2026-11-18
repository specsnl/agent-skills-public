---
name: feature-validation
description: Validate a proposed feature against the Product Definition and recommend Approve, Revise, or Reject with concrete alignment suggestions.
argument-hint: "[feature description or file]"
disable-model-invocation: true
---

# Feature Validation

Help the user check whether a proposed feature fits their product, based on their Product Definition.

Be friendly and brief. Use the user's language. Never show raw tool output.

## 1. Load the Product Definition

Look for `*-product-definition.md` in the current working directory. If there are several, ask which product the feature is for. If there is none, tell the user to run `/product-definition` first and stop.

## 2. Get the feature

Use `$ARGUMENTS` as the feature request: either a description or a path to a file that describes it. If it is empty, ask the user to describe the feature: what it does, for whom, and why.

If the request is too vague to validate (for example only a title), ask up to 3 short questions first, one at a time; wait for each answer before asking the next. The user may skip them.

## 3. Validate

Validate the feature with the [feature-validation-instructions](./feature-validation-instructions.md) and show the result.

## 4. Next step

- Revise: offer to validate an improved version of the feature.
- Reject or Approve: ask whether the user wants to validate another feature.
