# Product management plugin

A local-first toolkit that makes product management easier. It helps product teams define their
products, validate feature ideas, and make informed decisions based on strategy, user needs, and available
evidence.

The plugin works with a minimal set of Markdown files in the current working directory. Product Definition
establishes and maintains the Product Vision. Feature Validation uses that vision to assess proposed features.

**Define the product. Validate the features. Build what matters.**

## Installation

Claude: `claude plugin install product-management@specs-public`

Copilot: `copilot plugin install product-management@specs-public`

## Core principles

- Local-first: product information is stored and managed locally.
- Lightweight: minimal setup.
- Evidence-based: distinguish facts from assumptions.
- Product-aligned: validate features against the Product Definition.
- Outcome-oriented: focus on user and business value.
- Human-controlled: AI supports decisions but does not make them.

## Skills

| Skill                | Claude                | Copilot                                  | Purpose                                   |
|----------------------|-----------------------|------------------------------------------|-------------------------------------------|
| `product-definition` | `/product-definition` | `/product-management:product-definition` | Create or update a Product Definition     |
| `feature-validation` | `/feature-validation` | `/product-management:feature-validation` | Validate a feature against the definition |

Both skills only start from their slash command; Claude and Copilot do not start them on their own.

### product-definition

Claude: `/product-definition [FOLDER]`

Copilot: `/product-management:product-definition [FOLDER]`

Creates or updates `<product-name>-product-definition.md` in the current working directory from the product
documents in `FOLDER` (PDF, Word, PowerPoint, Markdown). Without a folder, the skill asks for one. It:

- Analyzes the available product information.
- Identifies missing information and assumptions.
- Asks targeted questions to clarify product direction.
- Defines target groups, needs, features, business goals, and differentiators.
- Generates and maintains a structured Product Vision.

The writing rules are in `skills/product-definition/product-definition-instructions.md`.

### feature-validation

Claude: `/feature-validation [FEATURE]`

Copilot: `/product-management:feature-validation [FEATURE]`

Validates a proposed feature, given as a description or a path to a file, against the `*-product-definition.md`
in the current working directory. Run `/product-definition` first when there is none. It:

- Assesses alignment with the Product Definition.
- Identifies the user problem the feature aims to solve.
- Evaluates expected user and business value.
- Identifies assumptions, risks, and trade-offs.
- Recommends Approve, Revise, or Reject, with concrete suggestions to align the feature.

The validation rules are in `skills/feature-validation/feature-validation-instructions.md`.
