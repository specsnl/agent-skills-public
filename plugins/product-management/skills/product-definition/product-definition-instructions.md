# Product Definition Instructions

## General

- Keep the output concise. Return clean markdown only.
- Use a bulleted list when the content consists of multiple items; otherwise use a paragraph.
- Only extract what the text explicitly states or strongly implies. Never invent or fabricate. If information is missing, write `Not found`.

## Subjects

Extract these subjects, in this order:

1. **Vision Statement**: a concise description of the desired future state the product aims to create
2. **Target Groups**: the users or customers the product is for, described by role, situation, or characteristics; no generic labels like "everyone" or "users"
3. **Needs**: problems to solve and/or value to add
4. **Product Features**: what the product enables; no UI elements or implementation details
5. **Business Goals**: outcomes the product should drive; no detailed metrics
6. **Differentiators**: what makes the product distinctly better or different from alternatives; no generic qualities like "easy to use" unless the source explains how they set it apart

Write every subject in this exact shape:

```markdown
## <Subject>
<extracted content as list or paragraph, or "Not found">

### Confidence
<High | Medium | Low>

**Evidence:** <exact quote or close paraphrase, or "No supporting evidence found">

### Contradictions
<one paragraph describing the contradiction with evidence, or "No contradictory content found.">
```

Confidence scale:

- High: clear, explicit, consistent evidence
- Medium: partial or indirect evidence
- Low: weak, ambiguous, or minimal evidence

Omit any claim you cannot support with evidence.

### Contradictions

Report only contradictions, inconsistencies, or tensions that are explicit or strongly implied, within or between source documents. Do not infer intent or fill gaps. Pay special attention to:

- Principles vs actual examples or ideas
- Stated constraints vs proposed solutions
- Metrics vs expected behavior
- "Always / never" statements vs exceptions
- Speed vs compliance, automation vs control, simplicity vs completeness

## Evaluation

After the subjects, add this block:

```markdown
### Completeness
<Complete | Partial | Incomplete>

### Strength
<High | Medium | Low>

## Suggestion
- ...
```

**Completeness**: are all six subjects present?

- Complete: all clearly present
- Partial: some missing or weak
- Incomplete: most missing

**Strength**: how usable is the product vision? Consider specificity, alignment between needs and features, concrete business goals, clarity of differentiation, and coherence (do all elements reinforce a single direction?).

- High: clear, specific, actionable
- Medium: partially defined, some ambiguity
- Low: vague, generic, not actionable

**Suggestion**: at most 3 bullets, kept separate from extracted content and without new facts. Focus on missing elements, weak or unclear needs, features that don't clearly solve a need, lack of differentiation, and misalignment between elements. If no useful suggestion can be made, write `Not found`.
