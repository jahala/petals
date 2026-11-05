# Repository Audit: petals

**Date:** 2026-07-20
**Auditor:** Claude Fable 5 (automated audit)
**Scope:** Full — architecture, code quality, tests, security, documentation, operability
**Branch:** `petals-release` (against `origin/master`)
**Commit count:** 32 · **Contributors:** 1 · **Merges:** 0

---

## 1. Verdict

**On track for an early open-source release, but shipping with a brand-split problem that undermines the product's central claim.** The deterministic check engine works correctly, tests pass, the architecture is clean. But the landing page — petals' own front door — uses a different color palette than the canonical brand it ships with, and fails its own check. The project's stated brand book fingerprint is stale. Fix these self-inconsistencies before the next public link is shared.

---

## 2. Scoreboard

| Metric | Value |
|--------|-------|
| Commits | 32 |
| Contributors | 1 |
| Merge commits | 0 (all direct pushes) |
| Test suites | 5 |
| Passing tests | 35/35 (100%) |
| Deleted test files (git history) | 1 (rename refactor) |
| TODO/FIXME/HACK in production | **0** |
| Dependency count | 0 (intentionally dependency-free) |
| Architecture docs | Missing (no architecture.md, engineering.md, decisions.md) |
| CI pipeline | Missing (recipes exist in docs, none wired) |
| Brand check on index.html | **FAIL** — 52 color errors, 106 warnings |
| Brand check on SKILL.md | **FAIL** — 3 color errors, 74 warnings |
| Brand book staleness | **DRIFTED** — fingerprint mismatch |

---

## 3. Findings, ranked

### FINDING-1 (CRITICAL) — Landing page uses different palette than canonical brand. CONFIRMED

**File:** `index.html:13-77`
**File:** `.brand/colors.md:12-14`

The landing page's `:root` block defines custom properties like `--pp-primary: #3F7A33`, `--pp-accent: #C04B3C`, `--pp-surface: #F0EDE1`, and `--pp-bg: #F8F5EC`. The canonical `colors.md` defines `--pp-primary: #357E2C`, `--pp-accent: #E89227`, `--pp-surface: #F5EEDD`, and `--pp-bg: #FAF5E9`. Every hex in the landing page is off by a noticeable amount — these are different colors, not the same palette warmed or cooled.

The landing page badge claims "this page passes /petals check" but running the check produces 52 color errors and 106 warnings.

**Root cause:** The landing page was designed with a pre-release or personal variant of the palette that was never reconciled with the canonical colors.md. Since the landing page's CSS is inline and self-contained, it silently diverged.

**Smallest root-cause fix:** Reconcile the index.html `:root` palette with `.brand/colors.md`. Every `--pp-*` custom property must match the corresponding hex in colors.md. Update the product-layer `products/petals/colors.md` if the intent was for petals to have its own hue offsets from the umbrella palette — but that product layer doesn't currently define any explicit colors; it inherits the umbrella. If local color adjustments are intentional, they must be documented in the product layer and verified by the check.

### FINDING-2 (CRITICAL) — Brand book is stale. CONFIRMED

**File:** `.brand/book.html:7`

The book declares `source-fingerprint: sha256:34f2bb2437b51db347ed08726d037f0edb05ffa04e75a36f63e24003e30c26d2`. Computing `sha256sum` across the 9 canonical source files (colors.md, typography.md, voice.md, identity.md, layout.md, components.md, products/petals/{colors,identity,voice}.md) produces a different hash. The book is out of date.

**Root cause:** The book was not regenerated after the last round of brand file changes. The `/petals book` regeneration command was never run as part of the release workflow.

**Smallest root-cause fix:** Regenerate `.brand/book.html` by running `/petals book`. (Or: `bash petals/scripts/export-tokens.sh` then re-render the book via the skill.) Add a verification step to the release process that checks book freshness before committing.

### FINDING-3 (HIGH) — Brand distribution source is a local absolute path. CONFIRMED

**File:** `.petalsrc:4`

The `.petalsrc` points to `source:` naming an absolute path on one developer's machine. This makes `.petalsrc` non-portable and prevents anyone else from connecting to the brand source. The drift detection script (`check-brand-drift.sh`) will report the source as unreachable for anyone without that exact filesystem layout.

**Root cause:** The brand was migrated from the plotplot umbrella repo via a local path while the distribution model was being designed, and the final GitHub-published source URL was never wired in.

**Smallest root-cause fix:** Publish `.brand/` from the plotplot umbrella repo to a reachable location (GitHub Pages, a dedicated brand repo, or a git URL) and update `.petalsrc` to point there instead. Verify with `bash petals/scripts/fetch-brand.sh <url>`.

### FINDING-4 (HIGH) — No governing doc suite. CONFIRMED

The project has no `docs/architecture.md`, `docs/engineering.md`, `docs/decisions.md`, or `docs/code-structure.md`. The PRD (`docs/petal-prd.md`) covers product intent but doesn't serve as an architecture reference. The SKILL.md has operational procedures but no development policies (dependency rules, test discipline, git workflow, review checklist, definition of done).

**Consequence:** An inheriting team cannot answer "how do we decide what to build?" or "what layer rules does this file violate?" or "what's the process for a change?" without reading the entire git log.

**Smallest root-cause fix:** Bootstrap the three core documents (or merge into the project's `.claude/CLAUDE.md`): architecture.md (one page: components, information model, core mechanism, security baseline), engineering.md (test-first, no mocks, pristine output, dependency policy), and decisions.md (starting with the fork/rename decision and the umbrella+product architecture choice).

### FINDING-5 (MEDIUM) — Deterministic check engine's `--fix` mode can mangle lines. CONFIRMED

**File:** `petals/scripts/check.sh:375-416`

The fix mode uses `sed -i ''` replacements that are line-based and don't understand CSS context. A line containing multiple hex values could have the wrong one replaced. The voice-fix section uses `perl -i -pe` for case-insensitive replacement, which could replace a word boundary match inside another word. There is no dry-run mode and no rollback (other than the `.bak` file).

**Consequence:** Running `--fix` on an unfamiliar file could silently introduce errors.

**Smallest root-cause fix:** Add a `--dry-run` flag that shows proposed changes without applying them. Document the experimental status of `--fix` mode. Consider replacing the line-based sed with the awk engine that already has the precise match data.

### FINDING-6 (MEDIUM) — Voice dimension's "product name lowercase" rule is over-broad. CONFIRMED

**File:** `petals/scripts/check.sh:312-338`

The voice check's product-name casing rule flags every lowercase occurrence of a product name (e.g., "petals", "tend", "tilth") as a warning — not only capitalized occurrences. The rule reads "product names are lowercase, always (voice.md)" and the deterministic engine warns on ALL instances because the regex matches literally lowercase text. When the name IS lowercase (as used correctly), it still warns. This produces ~50 false-positive warnings on the SKILL.md alone.

**Root cause:** The check logic and the rule are misaligned. The rule says "product names are always lowercase" (meaning: don't capitalize them). The check reads this as "lowercase is a violation" instead of "uppercase is a violation."

**Smallest root-cause fix:** Invert the check. The engine should warn only when it finds a capitalized instance (e.g., "Petals", "Tend"), not when it finds lowercase instances which are the correct form. This eliminates ~80% of the current voice warning noise.

### FINDING-7 (MEDIUM) — No CI pipeline. CONFIRMED

The README and SKILL.md include CI recipe snippets for GitHub Actions, but there is no `.github/workflows/` directory. Nobody runs tests or brand-checks automatically on push or PR. With only one contributor this hasn't been a problem, but it's invisible to anyone inheriting the project.

**Smallest root-cause fix:** Create `.github/workflows/test.yml` that runs all five spec files on push and PR. Add a brand-check step that verifies the landing page passes. This is a ~20-line file.

### FINDING-8 (MEDIUM) — Surface dimension doesn't verify component tokens against explicit spec. CONFIRMED

**File:** `petals/scripts/check.sh:278-311`

The surface audit checks radius values against a scale from `components.md` and flags pure-black shadows. But it doesn't validate shadow recipes against the documented ones (whether the `box-shadow` in the file matches the brand's shadow tokens), and it doesn't check `border-width` values against the stroke table. The SKILL.md spec says it should do all three; the engine only does radius and shadow-color-policy.

**Smallest root-cause fix:** Add box-shadow literal matching against the brand's shadow recipes in `components.md`, and border-width validation against the stroke token table.

---

## 4. What is genuinely good

1. **Architecture is clean and intentional.** Zero-dependency, file-based, shell scripts + awk + Python. No server, no database, no account. This makes it trivially installable and auditable. Every architectural decision is motivated in the PRD and SKILL.md with a clear rationale.

2. **The deterministic check engine is impressively capable.** 350 lines of bash-awk that does hex matching, Euclidean distance for nearest-color, WCAG contrast ratio calculation, spacing scale validation, breakpoint validation, radius matching, easing overshoot detection, shadow tint policy, forbidden term scanning, terminology enforcement, product-accent cross-linking, and product-name casing — all with zero external dependencies. The awk code is well-structured with named functions.

3. **All 35 tests pass.** Clean output, no skipped tests, no commented-out tests.

4. **Zero code-quality red flags.** No TODOs, no FIXMEs, no HACKs, no stubs, no mocks in production paths. The codebase is small and focused.

5. **The tend feature map is thorough.** 14 features, each with checks, audits, evidence, and status tracking. This is a high-discipline approach for a solo project.

6. **Error handling is exemplary for shell scripts.** Every script checks preconditions (file exists, directory exists, source reachable, tools available) before acting. Exit codes are distinct (4 separate exit codes in fetch-brand.sh alone). Error messages are specific and actionable.

7. **The brand book fingerprint mechanism is well-designed.** A sha256 sum of the canonical source files that the book can self-check against. The mechanism works; it's just a stale book that needs regeneration.

8. **The umbrella + product architecture is well-documented and implemented.** Clear separation: the umbrella carries shared truth, product layers are deltas only. The resolution logic in check.sh is correct.

---

## 5. Gap Register

| Gap | Owner | Acceptance Criteria |
|-----|-------|-------------------|
| Reconcile index.html palette with colors.md | executable-now | `bash petals/scripts/check.sh index.html` exits 0 with 0 errors (warnings may remain for voice) |
| Regenerate .brand/book.html | executable-now | Book fingerprint matches current sources; book check passes |
| Publish brand source to reachable URL | owner-decision | `.petalsrc` source field is a public git URL; `fetch-brand.sh` succeeds |
| Author docs/architecture.md | executable-now | Describes components, layer model, core mechanism with evidence status |
| Author docs/engineering.md | executable-now | Code rules, test discipline, git workflow, review checklist, definition of done |
| Author docs/decisions.md | executable-now | 3+ decision records including fork-to-petals rename and umbrella+product architecture |
| Create .github/workflows/test.yml | executable-now | Tests run on push/PR; landing page brand check passes as a gate |
| Fix product-name casing check logic | executable-now | Lowercase names pass silently; only capitalized names warn |
| Add shadow-recipe and stroke-width validation to surface audit | executable-now | `check.sh` validates `box-shadow` against documented recipes and `border-width` against stroke table |
| Create a runbook for brand-update releases | executable-now | Someone on the team can follow it without asking questions |

### Decision questions

| Question | Default if silent |
|----------|------------------|
| Where should the canonical petals brand source live? (dedicated repo `petals-brand`, umbrella repo `plotplot-ai/brand`, or GitHub Pages) | umbrella repo with `.brand/` at root, tagged |
| Should index.html use the umbrella palette exactly, or should petals have its own hue-shifted product layer? | umbrella palette exactly — product layer is for terminology and voice deltas only, not color shifts |
| Fix `--fix` mode (invest 1-2h) or remove it and recommend manual fix? | Remove the experimental fix mode; replace with a documented "read the report, apply manually" workflow |

---

## 6. Refuted Findings (Calibration)

- **Suspicion: "The deterministic engine doesn't catch all color errors."** Tested against 22 fixture files including edge cases (data URIs, URLs, CSS variables, JSX inline styles, cross-product accents). All pass or fail as expected. Color coverage is thorough.
- **Suspicion: "Tests mock the brand files."** Verified. Tests spin up temporary `.brand/` directories from fixtures. They test against real files with real palette data. No mocking.
- **Suspicion: "export-tokens.sh makes up token names."** Verified. It reads `:root` CSS blocks from colors.md as the canonical token-name source. Tokens that don't appear in the markdown tables are skipped. The verification phase checks every emitted hex against the palette. This is correct.
- **Suspicion: "Shell scripts are fragile."** Tested across 5 suites with 35 test cases. They handle missing files, network failures, auth failures, and edge cases appropriately. For shell scripts, they're unusually robust. The awk core of check.sh is well-structured with named functions and clear data flow.

---

## 7. Summary of what to protect during refactors

1. **The awk engine in check.sh** — it's the crown jewel. Keep the RGB distance, contrast math, and product-accent cross-referencing intact.
2. **The zero-dependency constraint** — don't add npm/Python dependencies for things shell+awk can do. The existing use of `python3` in export-tokens.sh is acceptable (for safe JSON generation) but should not spread.
3. **The error-handling pattern** — every script's guard clauses and distinct exit codes are a reference for how to write maintainable bash. Protect this convention with code review.
4. **The tend feature map** — it's the project's memory across sessions. Keep it current. The discipline of verifying checks, updating progress, and writing narratives is what makes the project navigable after weeks away.
5. **The explicit-only policy** — "never guess a hex" is a key differentiator. Protect it even when it slows down initial extraction.
