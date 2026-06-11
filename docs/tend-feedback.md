# Tend Feedback — from building petals end-to-end

A brain dump while it's fresh. Non-judgmental; just what bit us, what confused us,
and what's missing.

---

## 1. Hard blocker: `gatherShippedFiles` directories are hardcoded

**File:** `src/core/coverage.ts:126`

```ts
const dirs = ['src', 'schema', 'skills', 'templates', 'scripts', '.github/workflows'];
```

If your project's source lives in a directory not on this list (like `petals/`),
the coverage scanner finds zero files. `totalFiles: 0`, every `coverage_files`
claim becomes a ghost, and you get `coverage_path_missing` for everything.

There is **no configuration surface** — no garden field, no `.tendrc`, no CLI
flag, no env var. The list is hardcoded and the only way to change it is to edit
tend's source.

**What would fix it:** A `shipped_dirs` (or `coverage.dirs`) field on the garden
polyglot, so each project declares its own first-party directories. Default to
the current list for backward compatibility.

**Second-order:** The error message "is not a shipped source file" gives no
indication of WHY. We had to read tend's source to understand the hardcoded
list. The message should say something like _"not found in recognized source
directories: src, schema, skills, templates, scripts, .github/workflows."_

---

## 2. Greenfield repos: merge-base validation hits the initial commit

When the merge base with origin/master is the repo's first commit (which may
only have a `.gitkeep`), all `coverage_files` paths fail because they don't
exist at that commit. This is a greenfield-repo problem — the fix is "merge to
master so the merge base moves forward," but diagnosing it took hours.

**What would fix it:** Either detect the greenfield case (merge base has ≤1
non-tend file) and skip coverage-path-at-merge-base checks, or document the
"merge before you validate" requirement prominently.

---

## 3. Catalog polyglot scaffold: data persisted but no files created

We defined personas and opportunities via `tend_update_catalog`. The data
appeared in the catalog JSON (verified via `bash overview.html data | jq
.catalog`), but **no `.tend.html` polyglot files were created on disk**.
Clicking a persona in the tend UI produced a 404.

We ran `tend aggregate` → rebuilt features only. `tend sync` → touched existing
polyglots only. `tend validate` → reported `catalog_polyglot_missing` but had no
command to fix it. We spent hours trying every tool hoping one would scaffold
the missing files.

The fix was PR #27 (`catalog-scaffold` branch) which added the scaffold
side-effect to `tend_update_catalog`. But the mental model gap was significant:
we expected **one tool to do one thing**, and it wasn't obvious that the older
MCP version simply didn't have the scaffold path.

**What would fix it:** `tend validate` already detects `catalog_polyglot_missing`
— it should also offer a repair command (or `tend aggregate` should scaffold
persona/opportunity polyglots, not just feature polyglots).

---

## 4. `tend_update_catalog` replace semantics are a footgun

Sending `{ personas: [newOne] }` **replaces** the entire personas array — not an
upsert. A one-element array wipes the rest. You must read the current catalog
and send every entry you want to keep.

This is documented in the handoff doc but easy to miss. A merge/upsert semantic
(or at least a warning when the array shrinks) would prevent data loss.

---

## 5. Mental model: what lives where?

| Thing | Where it lives | How to create |
|-------|---------------|---------------|
| Feature | `docs/tend/features/<id>.tend.html` | `tend_create_feature` |
| Persona | `docs/tend/features/<id>.tend.html` | `tend_update_catalog` + approved |
| Opportunity | `docs/tend/features/<id>.tend.html` | `tend_update_catalog` + approved |

Everything is in `docs/tend/features/` — personas and opportunities don't get
their own directories. This is fine once you know it, but it's counterintuitive
(we expected `docs/tend/personas/` and `docs/tend/opportunities/`).

The "one tool authors the spine" rule (`tend_update_catalog` for personas and
opportunities, `tend_create_feature` for features) is another thing you have to
learn — calling `tend_create_feature` for a persona silently creates the wrong
thing.

---

## 6. What does each command actually do?

When things went wrong, we cycled through every available command hoping one
would fix it. The purpose and side effects aren't obvious from names alone:

| Command | Expected | Actual |
|---------|----------|--------|
| `tend aggregate` | Rebuild everything from disk | Rebuilds features only, skips personas/opportunities |
| `tend sync` | Sync everything | Refreshes existing polyglots + skills, doesn't create missing ones |
| `tend validate` | Find and optionally fix issues | Finds issues, no repair path |

**What would fix it:** A `tend repair` or `tend doctor` command that fixes
detectable issues (missing polyglots, stale index, drift). Or have `tend
validate --fix` apply the repairs.

---

## 7. MCP server caches code in memory

After rebuilding tend, MCP tools still ran the old code. You have to `pkill -f
'tend.*serve'` and let Claude Code respawn it. This is true for any MCP server
but worth documenting — we spent time debugging "fixed" behavior that hadn't
taken effect.

---

## 8. Slot-coherence: "every filled slot must have a check"

The constraint that every filled slot (`what`, `why`, `impact`, `fit`, `where`,
`how`) must have a check with `validates: "<slot>"` is a good rule, but it's
only surfaced as a warning after you've built everything. During
brainstorm/create, there's no prompt or validation that says "you filled `why`
— you need a check that validates it."

We ended up with 7 slot-coherence warnings across 3 features because we didn't
know this rule during creation.

---

## 9. "Thin steps" — steps need `Test:` blocks

Steps without a `Test:` block in their description get a `thin_steps` warning.
This is a great rule (enforces test-first thinking), but we only learned about
it from the validator after all steps were already written.

---

## 10. Greenfield onboarding: tend assumes brownfield

The primary flow (`/tend discover` → `/tend plan` → `/tend run` → `/tend
audit`) maps an existing codebase. Starting from scratch — ideas first, then
code — works but the path is less obvious:

1. `/tend brainstorm` → create features from ideas
2. `/tend plan` → write implementation steps
3. `/tend position` → define personas and opportunities
4. `/tend run` → implement
5. `/tend audit` → verify

Step 3 logically belongs before step 1 (personas define who you're building
for), but nothing enforces this ordering. We positioned after brainstorming and
had to retrofit persona bindings.

---

## 11. Evidence paths require "proof of execution"

The audit model wants `evidence_path` pointing to actual executed outputs (logs,
screenshots, terminal captures), not just file citations. This is good rigor but
wasn't obvious — we initially pointed evidence at the source files themselves
and had to fix it during audit.

---

## Summary: the three things that would have saved the most time

1. **Configurable shipped directories** — the hardcoded list is a wall for any
   non-standard project structure
2. **`tend repair` / `tend doctor`** — a command that detects and fixes common
   issues (missing polyglots, stale index, catalog drift) without having to
   understand every internal mechanism
3. **Create-time validation** — surface slot-coherence and thin-step rules during
   `/tend brainstorm` and `/tend plan`, not just at audit time
