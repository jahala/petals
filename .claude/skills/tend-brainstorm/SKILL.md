---
name: tend-brainstorm
description: Structure a new idea or external document (PRD, Jira/Linear export, plain text) into a tend feature polyglot with six slot claims, verifiable checks (each anchored to a slot), integration levels, and a smoke test. Trigger when a user has a new idea, a vague vision, or a doc to import.
user-invocable: false
---

# Brainstorm: Idea or Document -> Feature Polyglot

**Owns**: feature creation, the six slot strings (`what` / `why` / `impact`
/ `fit` / `where` / `how`), `checks[]`, `smoke`, `personas` / `solves` /
`journey_phase`, `entry_condition` / `exit_condition`, and the
project-level catalog (components, personas, opportunities, journey_phases).

## What this skill assumes

- The garden's `catalog.personas[]` has entries with `archetype` and `jobs[]` populated. If empty, redirect to `/tend position` — checks need bound persona-jobs to point at via `validates_job`.
- The garden's `catalog.opportunities[]` entries carry `personas[]`. New opportunities created during brainstorm are required to bind one or more personas.
- The user can articulate the feature in some form — an idea, a doc, or a list. If the user can't, that's a `/tend position` redirect (the spine question is upstream of feature-level work).
- Test-first discipline is non-negotiable: every check has a `verification_recipe`, every feature has a `smoke` or an explicit no-smoke decision logged.
- WWIFWWh slots are for capability bets. Persona / opportunity polyglots (those whose oo-data has `data.persona` or `data.opportunity` set) use their own field set — edit those via `/tend position`, not `/tend brainstorm`. Brainstorm refuses to slot a catalog description.

## Purpose

Take any input - a fresh idea or an existing doc - and produce a writable,
approved feature polyglot. The work is half capture, half interrogation:
every check is a real assertion you can verify, with a one-line
verification recipe attached. We're not just writing what the feature is;
we're forcing the question of how anyone would prove it works.

## Output

- `docs/tend/overview.html` - the garden polyglot's `oo-data.catalog` (via `tend_update_catalog`)
- `docs/tend/features/<id>.tend.html` - the feature polyglot (via `tend_create_feature`, then `tend_update_feature`)

## Rules

- Ask the user for choices and confirmation. Do not proceed on assumptions when intent is ambiguous.
- Checks must be **assertions** (checkable outcomes), not tasks.
- Check writing rules: one sentence, binary pass/fail, verifiable by reading code or running a test or observing behavior. No subjective words (fast, clean, good, simple, proper, appropriate).
- **Every check has a `validates` slot.** Ask, per check: "Which slot claim does this check anchor to?" Pick one of `what` / `why` / `impact` / `fit` / `where` / `how`. The slot pin keeps checks honest - no orphan checks that prove nothing in particular.
- **Every check has a `validates_job`** when the feature has bound personas with jobs. Ask, per check: "Which Klement Job Story does this check prove?" Format: `<persona_id>:<job_index>` (e.g., `"new-user:0"`). The persona's job validation clause (`personas[id].jobs[index].validation`) becomes the spec the check enforces — the test must assert that validation, not a paraphrase. If the feature's personas have no jobs yet, redirect to `/tend position` before brainstorming further checks (an unbound check is missing its human-grounded spec).
- **Every check has an `integration_level`.** Ask, per check: "How would this be verified in practice?" Pick:
  - `unit` - a single function call's return value is enough.
  - `integration` - multiple components must be wired together (DB + handler, parser + writer, etc.) and exercised together.
  - `e2e` - real runtime required: browser, server, filesystem, network, hardware. A mocked happy-dom test is NOT e2e.
  - `manual` - humans must verify (visual design, copy review, accessibility audit, real-device testing). No automated test will satisfy this.
  Default if you skip the question is `unit`. Don't skip the question.
- **Every check has a `verification_recipe`.** A one-line answer to "how do I know this check is satisfied?", concrete enough that the next person could write a failing test from it. Examples:
  - `"User can log in with valid credentials"` -> recipe: `"POST /auth/login with seeded user, expecting 200 and a valid JWT in the response body"` (integration)
  - `"Reset button starts a new game without page reload"` -> recipe: `"click the Reset button; assert board state cleared; assert no navigation event fires"` (e2e)
  - `"signJWT returns a token with exp claim 1h in the future"` -> recipe: `"call signJWT with a fixed now; decode result; assert payload.exp - now === 3600"` (unit)
  A check without a recipe is a check you do not understand yet. Don't write it.
- **Every check has a `method`.** Pick from `synthetic-test` (default) | `code-review` | `user-report` | `analytics-metric` | `agent-judgment`. Most checks are `synthetic-test`. Use `code-review` for static guarantees, `agent-judgment` for design/copy quality.
- **Every feature gets a `smoke`** (or an explicit "no smoke" decision logged). Ask: "If you could run one command to prove this whole feature actually works end-to-end, what would it be?" Capture as `smoke.cmd` (and optional `verify` regex/substring). For features that genuinely have no runtime to smoke-test (pure libraries with only unit-testable APIs, etc.), record the decision in `decisions[]` so future audits don't expect one.
- **Probe non-functional checks.** Before finalizing, ask the user about:
  - **Performance** - any latency / throughput / memory expectations? (often missing, often integration-level)
  - **Accessibility** - keyboard, screen reader, contrast (typically `manual` or `e2e`)
  - **Observability** - logs / metrics / errors visible somewhere? (often forgotten)
  - **Error handling** - what happens on bad input, network failure, partial write?
  - **Security** - flag for the planning skill if relevant; deeper analysis happens there.
  Add checks for each that the user confirms.
- **Cross-cutting check.** Before writing, ask: "Are any of these checks really cross-cutting properties - true for every feature, not specific to this one - that belong as a project-level quality gate rather than on this feature?" Examples: "all endpoints log structured JSON", "all UI is keyboard accessible". Flag for project-level capture.
- **Opportunity ↔ persona binding.** When proposing a new opportunity via `tend_update_catalog`, set `opportunity.personas: ["<persona-id>", …]` listing every persona feeling that pain. An opportunity with no `personas[]` is invented demand — surface it as a gap or drop it. Persona alignment: a feature's `personas[]` should overlap with the `personas[]` on each opportunity it `solves`; otherwise the feature is solving pain for someone who isn't actually targeted.
- **Present all checks to the user before writing.** Show each check with its `validates` slot, proposed `integration_level`, `method`, and `verification_recipe`. Ask: "Could each of these recipes be turned into a failing test by someone who reads them? Does the integration_level match the recipe? Any check to add, drop, or sharpen?" Revise based on feedback, then write. If the user accepts without changes, proceed - the goal is informed consent, not a quiz.
- Never write to tend without user confirmation of parsed/proposed features.
- Create features one at a time via `tend_create_feature`. Do not batch-synthesize into a single feature.
- For imports: preserve original requirement wording. Rewrite only for structural fit. The integration_level question still applies - original text doesn't carry that signal, you have to ask.
- Set both `dependencies` (technical blockers) and `enables` (user journey edges).
- Persist decisions into the polyglot via MCP - no chat-only conclusions.
- **Log decisions**: When the user picks an approach, makes a scoping choice, or decides to skip a smoke for a library-shaped feature, write to `decisions[]` via `tend_update_feature`. Each entry needs `id`, `at`, `decision`, `rationale`. Include `alternatives_considered` when multiple options were evaluated.
- After completion: single-sentence summary unless user requests more.

## Step 0: route

Ask once:

> "Are you starting from a new idea, or importing from an existing document (PRD, Jira/Linear export, plain text)?"

- **Idea** -> follow the [Idea Path](#idea-path)
- **Document** -> follow the [Import Path](#import-path)

If the user says "we have an existing codebase, map it" - that's the
`tend-discover` skill instead.

---

## Step 0.5: top-level feature or subpage?

**Run this gate before calling `tend_create_feature`.** A feature belongs at the top level only when it anchors to a user-journey moment — a persona performing a task verb (`orient`, `author`, `plan`, `build`, `verify`, `review`). If the thing being described is substrate, it belongs as a subpage of the surface it lives inside.

**Subpage signal** — any one of these present means subpage, not top-level:

- The WHAT slot describes a mechanism, primitive, helper, or internal contract rather than something a persona does. Examples: "file I/O layer", "polyglot assembler", "render scaffold", "extension contract", "CI pipeline configuration", "schema validation module", "sub-command of a larger CLI surface".
- There is no plausible Klement Job Story of the form *"when [situation], because [motivation], we believe [outcome], we'll know we got it right when [validation]"* — no persona-job validation clause can be written that naturally anchors a check to this concept.
- The concept would appear in the feature graph solely as infrastructure for another feature, with no user-visible exit condition of its own.

**Top-level signal** — all three must hold:

- A named persona performs a specific task verb at this surface.
- There is a user-visible entry and exit condition.
- Checks can be anchored to persona-job validation clauses without artificial stretching.

**The `journey_phase` field is the litmus test.** If you cannot assign one of `orient | author | plan | build | verify | review` to the concept without stretching, it is not a top-level feature.

**When subpage signal is present:**

1. Ask: "This looks like substrate or internal mechanism — what user-facing feature does it belong under? (For example: `auth`, `checkout`, `settings`, `onboarding`)"
2. If a parent feature already exists: scaffold as a subpage by calling `tend_create_feature` with basic fields, then `tend_update_feature` to set `parent: '<parent_id>'` (the create tool's schema does not accept `parent` directly). Omit `journey_phase` and top-level `dependencies` / `enables` — subpages are internal to the parent.
3. If no parent feature exists yet: surface this explicitly — "There is no top-level feature for this surface yet. Should we create the parent first, or is this concept out of scope?" Do not create an orphaned subpage. The parent comes first.
4. If you cannot determine the parent even after discussion: log the ambiguity in `decisions[]` and flag via `tend_get_gaps`. Do not silently proceed with a top-level feature that is really substrate.

---

## Idea Path

### 1. Check catalog

Use the polyglot's data verb to read the garden:

```bash
bash docs/tend/overview.html data | jq '.catalog'
```

If the catalog is empty or missing major pieces, fold them into the
clarification step below:

- "Who are the main users of this product?" -> populate `catalog.personas` with `[{ id, name, description }]`
- "What are the key stages of the user experience?" -> populate `catalog.journey_phases` as an ordered array

Only ask these once. Skip if already defined.

### 2. Identify components

For projects spanning multiple parts (backend, frontend, mobile, etc.),
identify all components and update the catalog via `tend_update_catalog`.
Each component: `id`, `name`, `tech[]`, `path`.

### 3. Clarify intent (the six slots)

Walk the user through the slots:

| Slot     | Question                                                                       |
|----------|--------------------------------------------------------------------------------|
| `what`   | What are we building? One sentence.                                            |
| `why`    | Why does it matter to the user?                                                |
| `impact` | If this works, what changes in the world?                                      |
| `fit`    | How does it fit the roadmap or strategy?                                       |
| `where`  | Where in the code does it live? Which component(s)?                            |
| `how`    | What's the technical approach (one-liner)?                                     |

Also collect:

- **In/Out**: what's in v1, what's explicitly out
- **Constraints**: platform, integrations, privacy, performance
- **Personas** and **journey_phases** (if not yet in catalog)
- **Opportunity**: "What problem does this solve? What evidence supports this need?" If new, call `tend_update_catalog` to add `catalog.opportunities` — include `personas: ["<persona-id>", …]` listing every persona feeling this pain (no anonymous opportunities). If it maps to an existing opportunity, note its `id` for the feature's `solves` field, and verify the opportunity's `personas[]` overlaps with the feature's `personas[]`.

The slots are top-level on the feature polyglot. Anything missing
surfaces as a gap-card via `tend_get_gaps`.

### 4. Explore approaches

Propose 2-3 approaches with trade-offs and risks. User chooses or accepts
the recommendation. MVP by default; expand scope only when required by
checks.

### 5. Define checks with verification per check

Draft checks one at a time. For each:

1. Write the check description.
2. Ask the user which slot it anchors to (`validates`).
3. Ask "which persona-job does this check prove?" — capture `validates_job` as `<persona_id>:<job_index>`. Read the persona's job validation clause aloud; it is the test's pass criterion. If the feature has no bound personas with jobs, redirect to `/tend position`.
4. Ask "how is this verified?" — capture `integration_level`.
5. Write the `verification_recipe` (the failing-test-in-prose) — it must encode the persona-job validation clause, not paraphrase it away.
6. Pick the `method`.

Probe non-functional checks the user may have skipped (performance,
accessibility, observability, error handling). Cross-check whether
anything belongs as a project-level quality gate instead.

### 6. Smoke test

Ask: "If you could run one command to prove this whole feature works
end-to-end, what would it be?" Capture as `smoke.cmd` (and optional
`verify` regex). For features with no runtime to smoke-test, log the
decision in `decisions[]` and move on.

### 7. Create the feature polyglot

```
tend_create_feature({
  id: "auth-login",
  title: "User Login",
  status: "planned",
  priority: "high",
  dependencies: [],
  enables: ["dashboard"],
  journey_phase: "orient",
  personas: ["new-user"],
  solves: ["opp-secure-access"],
  entry_condition: "User has created an account",
  exit_condition: "User reaches their dashboard with an active session",
  what: "Allow users to log in with email and password.",
  why: "A returning user can pick up where they left off.",
  impact: "Returning users complete sign-in in under 5 seconds.",
  fit: "Foundational for every authenticated feature in the roadmap.",
  where: "src/auth/handlers/login.ts; src/db/users.ts.",
  how: "POST /auth/login validates credentials with bcrypt, signs JWT, returns to client; session cookie set on success."
})
```

Then present the checks and `smoke` to the user, revise if needed, and
write via `tend_update_feature`:

```
tend_update_feature({
  id: "auth-login",
  changes: {
    checks: [
      {
        id: "c001",
        description: "User logs in with valid credentials and reaches the dashboard.",
        validates: "what",
        validates_job: "new-user:0",
        method: "synthetic-test",
        integration_level: "e2e",
        verification_recipe: "POST /auth/login with seeded user; expect 302 -> /dashboard; expect session cookie set."
      },
      {
        id: "c002",
        description: "Invalid credentials display an error without revealing which field is wrong.",
        validates: "what",
        validates_job: "new-user:0",
        method: "synthetic-test",
        integration_level: "integration",
        verification_recipe: "POST /auth/login with bad password; expect 401; expect error body contains 'credentials' but not 'email' or 'password'."
      },
      {
        id: "c003",
        description: "Login latency p95 < 500ms under 100 concurrent users.",
        validates: "impact",
        validates_job: "returning-user:1",
        method: "analytics-metric",
        integration_level: "e2e",
        verification_recipe: "k6 100vus 60s against /auth/login; assert p(95) < 500."
      }
    ],
    smoke: {
      cmd: "npm run test:e2e -- auth/login.smoke",
      verify: "all 5 tests passed"
    }
  }
})
```

### 8. Bind coverage_files (intent)

Call `tend_update_feature({ id, changes: { coverage_files: ["src/...", ...] } })` with the repo-relative paths the feature intends to touch. Ask: "Which source files will this feature create or modify?" Omit test files. This is an intent declaration — run will verify and extend it.

### 9. Set dependencies and enables

For each feature:

- `dependencies`: feature IDs that must be verified before this one can be built (work-order DAG)
- `enables`: feature IDs the user can reach after this one in their journey
- `priority`: `high` | `medium` | `low` based on value and risk

### 9. Approve

When the feature is stable, present it back to the user with a one-line
summary per slot. Feature stays at `status: "planned"` until steps start
(then `tend-plan` and `tend-run` advance it).

---

## Import Path

### 1. Receive source

Ask the user to provide the source:

> "Paste the content, or provide a file path or URL. Supported formats: markdown PRD, Jira CSV or JSON export, Linear JSON export, plain text requirements."

Read the content from the given source.

### 2. Identify format

| Signal                                              | Format        |
|-----------------------------------------------------|---------------|
| `## ` headers + check / requirement blocks          | Markdown PRD  |
| `Issue Key,Summary,Description,...` header row      | Jira CSV      |
| `{"issues": [...]}` or `{"data": {"issues": ...}}`  | Jira JSON     |
| `{"identifier":...,"title":...,"state":...}` array  | Linear JSON   |
| Numbered/bulleted requirements, no clear structure  | Plain text    |

If the format is unclear, ask the user before parsing.

### 3. Parse feature candidates

Extract from the source:

| Field               | Source mapping                                            |
|---------------------|-----------------------------------------------------------|
| `id`                | Slugify the title (lowercase, hyphens)                    |
| `title`             | Feature/issue title                                       |
| `what`              | Description or first paragraph - one-liner                |
| `why`               | "User value" or "rationale" section if present            |
| `checks[]`          | Acceptance criteria, definition of done - preserve wording, then add `validates`/`integration_level`/`recipe` per check |
| `priority`          | Map to `high` / `medium` / `low` (see below)              |
| `references[]`      | Source identifier (filename, URL, issue key)              |
| `dependencies`      | Features referenced as blockers                           |
| `enables`           | Features described as unlocked by or following this one   |

**Priority mapping:**

| External                | tend       |
|-------------------------|------------|
| Highest / P0 / Must     | `high`     |
| High / P1 / Should      | `high`     |
| Medium / P2 / Could     | `medium`   |
| Low / P3 / Won't (yet)  | `low`      |
| Unset                   | ask user   |

Don't assume structure - parse what is actually present. Missing fields
stay absent and surface as gap-cards later.

### 4. Probe verification (the import doesn't tell you)

External docs almost never carry `integration_level`, `validates`, or
verification recipes. For each parsed check, you still ask:

- Which slot does this anchor to? (validates)
- Which persona-job does this prove? (validates_job)
- How would this be verified in practice? (integration_level)
- What's the failing-test-in-prose? (verification_recipe)

For each parsed feature, ask the smoke question. The import gave you the
WHAT; brainstorm captures the HOW-IS-IT-PROVEN.

### 5. Review with user

Present all parsed candidates with proposed fields before writing:

```
Found N features to import:

1. [auth-login] User Login
   priority: high
   slots:
     what:  Allow users to log in with email and password.
     why:   (gap)
     impact:(gap)
     ...
   checks: 3 items
     - c001 [what/e2e]:         User logs in with valid credentials...
       recipe: POST /auth/login with seeded user; expect 302 -> /dashboard
     - c002 [what/integration]: Invalid credentials show error...
     - c003 [impact/e2e]:       Login latency p95 < 500ms...
   smoke: npm run test:e2e -- auth/login.smoke
   dependencies: (none)
   enables: auth-password-reset
   refs: PRD-auth.md

2. [auth-password-reset] Password Reset
   ...

Proceed with all, or specify which to skip or edit?
```

Incorporate corrections before proceeding.

### 6. Create features

For each approved candidate, call `tend_create_feature` with the parsed
slot data. Then `tend_update_feature` to add `checks` and `smoke`.
Include a `references` entry pointing to the source document.

If a dependency or enables target does not yet exist, note it as a
forward reference and resolve after all features are created.

### 7. Resolve relationships

After all features are created:

- Read the catalog: `bash docs/tend/overview.html data | jq '.features_aggregate'`
- Update `dependencies` and `enables` on affected features via `tend_update_feature`

---

## Done When

- Catalog exists with components (if multi-component), `journey_phases`, and `personas`
- Each feature has: at least `what` and `why` populated (other slots optional but surfaced as gaps), `checks[]` where each check has `validates`, `validates_job` (when the feature has bound personas with jobs), `integration_level`, `method`, and `verification_recipe`
- Each feature has either a `smoke` (cmd, optional verify) OR a `decisions[]` entry explaining why none is appropriate
- Imported features also have a `references` entry linking to the source
- Every new opportunity created via this skill has `personas: [...]` set (no anonymous opportunities)
- `dependencies` AND `enables` are set for each feature
- Non-functional concerns (performance, accessibility, observability, error handling) were probed
- Cross-cutting properties were flagged and either lifted to catalog quality gates or scoped onto the right feature
- User confirmed all checks (with `validates` / `integration_level` / `recipe`) and `smoke` before any writes
- Unknowns are explicitly marked, not silently skipped

## Suggested Next Steps

- To plan implementation steps with test-first descriptions: `/tend plan`
- To verify what's already built (if any): `/tend audit`
- To map an existing codebase to features instead: `/tend discover`
