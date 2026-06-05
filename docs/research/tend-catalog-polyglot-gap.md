# Tend Catalog Polyglot Gap — Repro & Debug Notes

**Date:** 2026-06-04
**For:** tend developer(s)

## Problem

Personas and opportunities defined via `tend_update_catalog` have complete data in the catalog JSON (descriptions, archetypes, jobs, personas bindings) but the physical `.tend.html` polyglot files are never created on disk. Clicking a persona or opportunity in the tend UI produces a 404 — no file exists at the expected path.

## What Exists

```
docs/tend/
├── overview.html                           # Garden polyglot (exists, works)
├── features/
│   ├── brand-extraction.tend.html           # Created by tend_create_feature (works)
│   ├── brand-distribution.tend.html         # Created by tend_create_feature (works)
│   └── brand-check.tend.html               # Created by tend_create_feature (works)
├── adapters/
│   └── markdown.json
└── catalog.json
```

**Missing:**
```
docs/tend/personas/brand-operator.tend.html      # DOESN'T EXIST
docs/tend/personas/shipping-developer.tend.html   # DOESN'T EXIST
docs/tend/personas/ai-agent.tend.html             # DOESN'T EXIST
docs/tend/opportunities/agent-off-brand.tend.html # DOESN'T EXIST
docs/tend/opportunities/pdf-to-agent-gap.tend.html# DOESN'T EXIST
docs/tend/opportunities/distribution-drift.tend.html # DOESN'T EXIST
docs/tend/opportunities/review-bottleneck.tend.html  # DOESN'T EXIST
docs/tend/opportunities/context-waste.tend.html      # DOESN'T EXIST
```

## What Was Tried

### 1. `tend_update_catalog` (MCP)
- Called repeatedly with full persona and opportunity data
- Data persists in the catalog JSON (confirmed via `bash docs/tend/overview.html data | jq '.catalog'`)
- **Side-effect not implemented:** The MCP tool's "automatic mirroring" into persona/opportunity polyglot files documented in the tend-position skill does not occur in this MCP version

### 2. `tend-cli aggregate`
- Command: `tend-cli aggregate`
- Output: `aggregated: rebuilt=3, removed stale=0, subpages rebuilt=0`
- Only rebuilds features (3 feature polyglots). Does not touch personas or opportunities.

### 3. `tend-cli sync`
- Command: `tend-cli sync`
- Output: `4 polyglots refreshed` (garden + 3 features) + `7 skills refreshed`
- Only touches existing polyglots + skill directories. Does not create persona/opportunity files.

### 4. `tend-cli validate`
- After aggregate + sync, validator still reports:
  ```
  catalog_polyglot_missing: Persona "brand-operator" has no description polyglot on disk
  catalog_polyglot_missing: Persona "shipping-developer" has no description polyglot on disk
  catalog_polyglot_missing: Persona "ai-agent" has no description polyglot on disk
  catalog_polyglot_missing: Opportunity "agent-off-brand" has no description polyglot on disk
  catalog_polyglot_missing: Opportunity "pdf-to-agent-gap" has no description polyglot on disk
  catalog_polyglot_missing: Opportunity "distribution-drift" has no description polyglot on disk
  catalog_polyglot_missing: Opportunity "review-bottleneck" has no description polyglot on disk
  catalog_polyglot_missing: Opportunity "context-waste" has no description polyglot on disk
  ```
- Validator recognizes the gap but there's no command or MCP tool to fix it

### 5. `tend-cli --help`
- No create/scaffold command for personas or opportunities
- Available commands: `init`, `rename`, `serve`, `ui`, `validate`, `aggregate`, `sync`, `execute`, `next`, `audit`

### 6. `tend_create_feature` (MCP)
- Only accepts feature-shaped payloads. Refuses persona/opportunity fields.
- Creates `docs/tend/features/<id>.tend.html` — not applicable to catalog items.

### 7. `tend_update_feature` (MCP)
- Works on existing polyglots by id. No way to target a persona or opportunity.

## Data Integrity

Despite the missing files, the catalog data is complete and correct:

```json
{
  "personas": [
    {
      "id": "brand-operator",
      "name": "Brand Operator",
      "description": "Maria opens her laptop at 9pm...",
      "archetype": "A senior developer or tech lead who translates...",
      "jobs": ["When the brand team sends me...", ...]
    },
    {
      "id": "shipping-developer",
      "name": "Shipping Developer",
      "description": "Sam is reviewing 12 PRs...",
      "archetype": "A frontend or full-stack developer...",
      "jobs": ["When I'm about to review 12 PRs...", ...]
    },
    {
      "id": "ai-agent",
      "name": "AI Agent",
      "description": "The agent opens a session...",
      "archetype": "A Claude Code agent...",
      "jobs": ["When I open a new session...", ...]
    }
  ],
  "opportunities": [
    {
      "id": "agent-off-brand",
      "description": "An agent opens a session...",
      "value": "critical",
      "confidence": "high",
      "source": "Observed in every AI coding tool...",
      "personas": ["brand-operator", "shipping-developer", "ai-agent"]
    },
    // ... 4 more
  ]
}
```

Features reference these correctly:
- `brand-extraction.personas`: `["brand-operator", "shipping-developer", "ai-agent"]`
- `brand-extraction.solves`: `["pdf-to-agent-gap", "agent-off-brand"]`
- `brand-distribution.personas`: `["brand-operator"]`
- `brand-distribution.solves`: `["distribution-drift", "agent-off-brand"]`
- `brand-check.personas`: `["shipping-developer", "ai-agent"]`
- `brand-check.solves`: `["review-bottleneck", "context-waste", "agent-off-brand"]`

## What's Needed

A mechanism to materialize catalog persona and opportunity entries into physical polyglot files. Options:

1. **`tend_create_feature` should accept persona/opportunity kinds** — or a separate `tend_create_catalog_entry` MCP tool
2. **`tend-cli aggregate` should create persona/opportunity polyglots** — currently it only handles features
3. **`tend_update_catalog` should have the side-effect** — the tend-position skill documents this as existing: "MCP side-effects mirror each persona and opportunity into its matching catalog-description polyglot automatically" — but it doesn't appear to be implemented in this version (tend-cli 1.0.0, MCP 0.4.0)
4. **A new `tend-cli` command** like `tend scaffold-catalog` that generates the missing polyglots from existing catalog data

## Workaround Being Attempted

None successfully. The data is correct but files can't be created. The project is structurally valid (cross-ref errors: 0) — it's purely a file-creation gap.

## Environment

- `tend-cli`: 1.0.0 (installed globally, symlinked from `/Users/jahala/conductor/workspaces/feature-map/missoula`)
- MCP server version: 0.4.0 (embedded in polyglot `tend_version` field)
- Project: `docs/tend/overview.html`, project_id: `petals`
