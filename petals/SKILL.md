---
name: petals
description: >-
  Brand compliance and design system skill. Use this skill when:
  - Building UI, components, layouts, landing pages, or any visual output
  - Writing copy, headlines, CTAs, microcopy, error messages, or marketing text
  - Checking if generated code/copy is on-brand (colors match palette, typography follows hierarchy, voice follows rules)
  - Extracting brand assets into a structured .brand/ directory from source files (PDFs, images, markdown, JSON)
  - Setting up or updating a project's brand context from a central brand repository
  - Any creative work where brand consistency matters — colors, typography, voice, UI, copy, compliance
---

# petals — Brand Intelligence for Agents

## Auto-Trigger Conditions

This skill activates automatically when an agent:
1. Generates UI code (HTML, CSS, React, Vue, Svelte, Tailwind, etc.)
2. Writes copy (headlines, CTAs, marketing text, microcopy, error messages)
3. Builds components, layouts, or landing pages
4. References brand assets (logos, color palettes, typography)

When activated, read the relevant `.brand/` file(s) BEFORE generating output:
- UI/visual work → `.brand/DESIGN.md` or `.brand/colors.md`
- Typography decisions → `.brand/typography.md`
- Copywriting → `.brand/voice.md`
- Logo/asset usage → `.brand/assets/` and `.brand/identity.md`

## Hard Validity Rules

These are non-negotiable. Violating any is a brand error.

1. **Colors from palette only** — Every hex value in generated output must match a value defined in `.brand/colors.md`. Never use arbitrary colors, even if they "look similar."
2. **Typography hierarchy** — Heading and body fonts must match `.brand/typography.md` exactly (family, weight, size). No font substitutions.
3. **Logo from assets** — Never invent, approximate, or text-describe a logo. Use files from `.brand/assets/` or skip the logo.
4. **Voice rules** — Generated copy must not contain forbidden terms listed in `.brand/voice.md`. Follow tone, grammar, and vocabulary rules.
5. **Conflict: brand wins** — When brand rules conflict with framework defaults, the brand rules win. Override Tailwind config, CSS resets, and component library defaults to match `.brand/`.

## Subcommand Dispatch

| Command | Description |
|---------|-------------|
| `/petal init <folder>` | Scan folder for brand assets and create `.brand/` directory |
| `/petal init --from <repo-url>` | Fetch `.brand/` from a central brand repository |
| `/petal check [file]` | Audit file against brand rules; if no file, check for brand drift |
| `/petal voice <text>` | Check copy against `.brand/voice.md`; return score and suggestions |
| `/petal color <name>` | Look up a specific color from `.brand/colors.md` |
| `/petal token <format>` | Export design tokens in specified format (css, tailwind, dtcg) |
| `/petal update` | Sync `.brand/` with latest from central, preserving project overrides |
| `/petal logo [variant]` | Return the correct logo asset path for the requested variant |

## Reference Workflow

Load reference files on demand based on the task:

| Task | Load |
|------|------|
| Extracting brand from assets | `references/extraction-guide.md` |
| Populating output templates | `templates/DESIGN.md`, `templates/colors.md`, `templates/typography.md`, `templates/voice.md`, `templates/identity.md`, `templates/components.md` |
| Auditing colors | `.brand/colors.md`, `references/color-audit-guide.md` |
| Auditing typography/spacing | `.brand/typography.md` |
| Auditing surface (radius/shadow/motion) | `.brand/components.md` |
| Auditing voice | `.brand/voice.md`, `references/voice-guide.md` |
| Auditing output (all dimensions) | `references/color-audit-guide.md`, `references/voice-guide.md`, `.brand/*.md` |
| Generating UI | `.brand/DESIGN.md`, `.brand/colors.md`, `.brand/typography.md`, `.brand/components.md` |
| Writing copy | `.brand/voice.md`, `.brand/identity.md` |

## /petal init Workflow

When `/petal init <folder>` is invoked, follow the extraction process documented in `references/extraction-guide.md`. Core principles:

1. **Explicit only** — only write values explicitly stated in source. Never infer hex from color names, weights from font names, or examples from tone descriptions.
2. **Flag ambiguity** — when a value is missing or unclear, flag it in the output with a clear question.
3. **Copy assets verbatim** — use `cp` or equivalent to copy asset files (SVGs, PNGs, JPGs, fonts) to `.brand/assets/`.
4. **Use templates** — populate `templates/*.md` with extracted values to produce `.brand/*.md`.
5. **No external tools** — use only native agent capabilities: file reading, vision, parsing, Bash for file operations.

## /petal init --from Workflow (Distribution)

When `/petal init --from <repo-url>` is invoked, the agent connects the project to a central brand repository and fetches `.brand/` into the local project.

### Distribution model

The central brand repository is a git repository with `.brand/` at its root. Projects pull `.brand/` from it — they do not commit `.brand/` themselves. `.brand/` is a cache. `.petalrc` at the project root records where the brand came from and which version is in use.

```
Central brand repo (github.com/company/brand, tagged v1.2.0)
        |
        |  fetch-brand.sh
        v
Project .brand/  (gitignored — cache, not source)
Project .petalrc  (committed — source, version, overrides)
```

### Step-by-step process

1. **Check for existing .brand/** — If `.brand/` already exists, warn the user:
   ```
   .brand/ already exists (version v1.1.0 from github.com/company/brand).
   Running init --from will overwrite it. Continue? (y/N)
   ```
   Wait for confirmation. If denied, exit without changes. If `.brand/` does not exist, proceed.

2. **Check for existing .petalrc** — If `.petalrc` already exists, do NOT modify it without confirmation. Warn:
   ```
   .petalrc already exists with source: github.com/other/repo.
   Overwriting will change the brand source. Continue? (y/N)
   ```
   Wait for confirmation.

3. **Run fetch-brand.sh** — Execute the fetch script with the provided repo URL:
   ```bash
   bash petals/scripts/fetch-brand.sh <repo-url> --target .brand
   ```
   The script auto-selects the best strategy (local path, git clone, GitHub API, raw HTTP). If the script exits non-zero, report the error to the user and STOP. Do not create or modify any files.

4. **Record source and version in .petalrc** — Parse the JSON output from fetch-brand.sh to get the version. Create or update `.petalrc`:
   ```yaml
   brand:
     source: <repo-url>
     version: <detected-version>   # e.g. v1.1.0
     overrides: {}
   ```
   The `overrides` map starts empty. Users add entries to override specific brand values for this project (see Override format below).

5. **Add .brand/ to .gitignore** — Check if `.gitignore` exists. If not, create it. Append `.brand/` to `.gitignore` if not already present. Use:
   ```bash
   grep -qxF '.brand/' .gitignore 2>/dev/null || echo '.brand/' >> .gitignore
   ```

6. **Verify output** — Confirm the output is correct:
   - `.brand/` directory exists and contains files
   - `.petalrc` exists with `source`, `version`, and `overrides` fields
   - `.gitignore` contains `.brand/`
   - `git status` does not show `.brand/` as untracked (if in a git repo)

7. **Report summary** — Tell the user:
   ```
   Connected to brand: <repo-url>
   Version: <version>
   Files in .brand/: <count>
   .brand/ is gitignored (cache, not source code)
   ```

## /petal update Workflow (Sync)

When `/petal update` is invoked, the agent syncs the local `.brand/` with the latest version from the central repository while preserving project-level overrides.

### Step-by-step process

1. **Verify the project is connected** — Read `.petalrc`. If it does not exist or has no `brand.source` field:
   ```
   This project is not connected to a brand source.
   Run /petal init --from <repo-url> first.
   ```
   Stop.

2. **Back up current .brand/** — Before making any changes, back up the current `.brand/` directory:
   ```bash
   cp -r .brand .brand.backup
   ```
   This ensures the current state is preserved if anything fails.

3. **Read current overrides** — Parse `.petalrc` to extract the `overrides` map. Each override is a flattened key with a dot-separated path:
   ```yaml
   overrides:
     colors.primary: "#custom-hex"    # non-null: preserve this value
     typography.body: null             # null: inherit from central
   ```
   Store these in memory for the merge step.

4. **Run fetch-brand.sh** — Fetch the latest `.brand/` from the central source:
   ```bash
   bash petals/scripts/fetch-brand.sh <source-from-petalrc> --target .brand.incoming
   ```
   Fetch into a temporary directory `.brand.incoming`, NOT directly into `.brand/`. If the script exits non-zero, restore from backup and report the error.

5. **Detect version from incoming** — Read the version from the fetched `.brand.incoming/identity.md` or from the fetch script output. Compare with `.petalrc` version. If they are the same:
   ```
   Brand is already at the latest version (<version>). Nothing to update.
   ```
   Clean up `.brand.incoming` and `.brand.backup`. Stop.

6. **Merge overrides** — For each override in `.petalrc`:
   - **Non-null value** (e.g., `colors.primary: "#OVERRIDE"`): Find and replace the corresponding value in `.brand.incoming/` files. The exact replacement strategy depends on the file format:
     - For `.brand/colors.md`: Replace the hex value in the table row and CSS custom property.
     - For `.brand/typography.md`: Replace the font family, weight, or size in the table row.
     - For `.brand/voice.md`: Replace the specific term or rule.
   - **Null value**: Do nothing — the central's current value will be used (it is already in `.brand.incoming/`).

7. **Apply the update** — Replace the live `.brand/` with the merged incoming:
   ```bash
   trash .brand
   mv .brand.incoming .brand
   ```

8. **Update .petalrc version** — Update the `version` field in `.petalrc` to the new version tag.

9. **Clean up** — Remove the backup:
   ```bash
   trash .brand.backup
   ```

10. **Report summary** — Tell the user:
    ```
    Updated brand from <old-version> to <new-version>.
    Preserved <N> override(s): <list of preserved keys>
    Updated <M> inherited values.
    ```

## /petal check (Drift Detection)

When `/petal check` is invoked without a file argument, it checks for brand drift — whether the central repository has a newer version than what is cached locally.

### Step-by-step process

1. **Read .petalrc** — Get the `source` and `version` fields. If `.petalrc` does not exist:
   ```
   No brand source configured. Run /petal init --from <repo-url> first.
   ```
   Stop.

2. **Fetch central version** — Run fetch-brand.sh in a dry-run mode, or query the source directly:
   - For local paths: Read `.brand/identity.md` from the source directly.
   - For git repos: `git ls-remote --tags <repo-url>` and take the highest semver tag.
   - For GitHub URLs: Use the GitHub API `GET /repos/:owner/:repo/releases/latest` or `GET /repos/:owner/:repo/git/refs/tags`.
   - For raw HTTP: Fetch `identity.md` from raw.githubusercontent.com.

   If the central source is unreachable:
   ```
   Warning: Cannot reach brand source (<source-url>).
   Local .brand/ at version <local-version> is preserved unchanged.
   Error: <specific error>
   ```
   Do not modify any local files. Exit gracefully.

3. **Compare versions** — Compare the local version (from `.petalrc`) with the central version:
   - If **local == central**: No output. Nothing to report. (No noise when current.)
   - If **local < central**: Report the drift:
     ```
     Brand drift detected.
     Local:  <local-version>
     Central: <central-version>
     Run /petal update to sync.
     ```
   - If **local > central**: This is unusual (local ahead of central). Report:
     ```
     Local brand (<local-version>) is ahead of central (<central-version>).
     This may indicate the central repo was rolled back. Review before updating.
     ```

## /petal check `<file>` (File Audit)

When `/petal check <file>` is invoked with a file argument, the agent audits the file against `.brand/` rules across up to five dimensions: color, typography, spacing, surface, and voice. The audit follows progressive disclosure: each dimension only loads the `.brand/` file it needs.

### Guard clause

Before any audit, verify the project is configured:

1. Check if `.brand/` directory exists. If not:
   ```
   No brand configured. Run /petal init --from <url> to connect to a central brand repo.
   ```
   Exit non-zero. Do not proceed.

2. If `.brand/` exists, proceed dimension by dimension. Each dimension checks for its specific file and skips gracefully if missing (see per-dimension guard clauses).

### Dimension 1: Color Audit

**Load**: `.brand/colors.md` (only this file — do not load DESIGN.md, typography.md, or voice.md). If `.brand/colors.md` does not exist, skip this dimension and report: `SKIP [color] colors.md not found. Skipping color audit.`

**Process** (follows `references/color-audit-guide.md`):

1. Extract every hex color from `.brand/colors.md`. Build a palette set (uppercase-normalised for case-insensitive matching).
2. Read the target file and scan line by line for hex color patterns using regex: `#[0-9a-fA-F]{3}\b`, `#[0-9a-fA-F]{6}\b`, and `#[0-9a-fA-F]{8}\b`.
3. For each match, check if it appears in a false-positive context and skip if so:
   - Inside `url("data:image/...)` strings (data URIs)
   - Inside long base64 strings (strings >100 chars containing only `[A-Za-z0-9+/=]`)
   - Inside `url(...)` that references external resources (does not start with `data:`)
4. For each remaining match, normalise case and check against the palette set:
   - **Match found**: No violation. Continue.
   - **No match**: This is an **error**. Find the closest palette color by computing Euclidean distance in RGB space: `sqrt((R1-R2)^2 + (G1-G2)^2 + (B1-B2)^2)`. For 3-digit hex, expand to 6-digit first (`#RGB` -> `#RRGGBB`).
5. Report each color mismatch as:
   ```
   ERROR [color] line <N>: <found-hex> is not in the palette. Did you mean <closest-palette-match>?
   ```

If zero color violations:
```
PASS [color] All colors match the brand palette.
```

### Dimension 2: Typography Audit

**Load**: `.brand/typography.md` (only this file). If `.brand/typography.md` does not exist, skip and report: `SKIP [typography] typography.md not found. Skipping typography audit.`

**Process**:

1. Extract font families from `.brand/typography.md`: heading font and body font (from the "Font Families" table).
2. Read the target file and scan for `font-family` declarations. In CSS, JSX/TSX, and other code files, look for patterns like:
   - `font-family: 'Raleway'` / `fontFamily: 'Raleway'`
   - `font-family: "Open Sans"` / `fontFamily: "Open Sans"`
3. For each `font-family` declaration, determine if the element is a heading or body:
   - Headings: `h1`, `h2`, `h3`, `h4`, `h5`, `h6` elements, or class names containing `heading`, `title`, `headline`
   - Body: `p`, `span`, `div`, `body`, `li`, `a`, `button`, `label`, `input` elements, or class names containing `body`, `text`, `content`, `paragraph`, `copy`
   - If the role is ambiguous (generic `div` or `span` without clear context), default to body-level checking.
4. Check each declaration:
   - **Heading element uses heading font**: No violation.
   - **Heading element uses body font**: Warning (suggest heading font).
   - **Body element uses body font**: No violation.
   - **Body element uses heading font**: **Error** — body text must use the body font.
5. Report typography errors as:
   ```
   ERROR [typography] line <N>: '<found-font>' used for body text. Body must use '<body-font>'.
   ```

If zero typography violations:
```
PASS [typography] Font families match the brand hierarchy.
```

### Dimension 3: Spacing Audit

**Load**: `.brand/typography.md` (specifically the "Spacing Scale" section — spacing lives in typography.md). If no spacing scale is defined, skip and report: `SKIP [spacing] No spacing scale defined. Skipping spacing audit.`

**Process**:

1. Extract the spacing scale from `.brand/typography.md`. If a "Spacing Scale" section exists, parse the values (e.g., `4px, 8px, 12px, 16px, 20px, 24px, 32px, 40px, 48px`). If the scale is expressed as "multiples of N", compute the set of valid multiples.
2. Read the target file and scan for `px` values in padding, margin, gap declarations:
   - `padding: <N>px`, `margin: <N>px`, `gap: <N>px`
   - `padding-top`, `padding-bottom`, `margin-left`, etc.
   - JSX equivalents: `padding: <N>`, `marginTop: <N>` (values in px)
3. For each px value, check against the spacing scale:
   - **Matches a scale value (or an exact multiple)**: No violation.
   - **Does not match**: **Warning** (not an error). Find the two nearest scale values and suggest the closest.
4. Report spacing warnings as:
   ```
   WARNING [spacing] line <N>: <N>px is outside the spacing scale. Did you mean <closest-scale-value>px?
   ```

If zero spacing warnings:
```
PASS [spacing] All spacing values match the brand scale.
```

### Dimension 4: Surface Audit

**Load**: `.brand/components.md` (only this file). If `.brand/components.md` does not exist, skip and report: `SKIP [surface] components.md not found. Skipping surface audit.`

**Process**:

1. Extract the token tables from `.brand/components.md`: the radius scale, border-stroke widths, shadow recipes (and their stated color policy), and motion tokens (easings, durations).
2. Read the target file and scan for surface declarations:
   - `border-radius: <value>` (and JSX `borderRadius`)
   - `box-shadow: <value>` (and JSX `boxShadow`)
   - `border: <width> …` / `border-width`, `outline` widths
   - `transition: … <duration> <easing>`, `animation: … <duration> <easing>`, `transition-timing-function`, `animation-timing-function`
3. Check each declaration against the tokens:
   - **Radius**: a value not on the radius scale (allowing `999px`/`50%` as radius-full) is a **warning** — suggest the nearest scale value.
   - **Shadow**: a shadow violating the stated color policy (e.g. pure `#000` / un-tinted `rgba(0, 0, 0, …)` where the brand specifies tinted shadows) is a **warning** — name the policy.
   - **Border width**: a width not in the stroke table is a **warning** — suggest the nearest stroke.
   - **Easing**: a bounce/elastic easing (e.g. `cubic-bezier` with an overshoot, `ease-in-out-back`) or any easing/duration far outside the motion tokens is a **warning** — name the brand ease. Anything in the brand's forbidden-motion list is an **error**.
   - Skip values inside data URIs and third-party vendored code, mirroring the color audit's false-positive rules.
4. Report as:
   ```
   WARNING [surface] line <N>: <found-value> is off the <radius|stroke|shadow|motion> tokens. Did you mean <closest-token>?
   ```

If zero surface violations:
```
PASS [surface] Radius, borders, shadows, and motion match the surface tokens.
```

### Dimension 5: Voice Audit (within check)

If the target file contains text content (copy strings, comments with user-facing text, JSX text nodes), also run the voice audit. See `/petal voice` workflow below for the detailed process.

**Load**: `.brand/voice.md` (only if text content is detected — progressive disclosure: skip loading voice.md if the file has no text content).

### Summary Report

After all dimensions complete, print a summary:

```
--- brand check summary ---
Colors:   <N> error(s), <M> warning(s)
Typography: <N> error(s), <M> warning(s)
Spacing:  <N> error(s), <M> warning(s)
Surface:  <N> error(s), <M> warning(s)
Voice:    <N> error(s), <M> warning(s)

Result: <PASS (all dimensions clean) | FAIL (<X> error(s) to fix, <Y> warning(s) to review)>
```

Exit 0 if zero errors (warnings alone do not fail the check). Exit non-zero if any errors exist.

## /petal voice `<text-or-file>`

When `/petal voice <text-or-file>` is invoked, the agent audits the provided text or file content against `.brand/voice.md` rules. This can be used standalone or as part of `/petal check <file>`.

### Guard clause

1. Check if `.brand/` directory exists. If not:
   ```
   No brand configured. Run /petal init --from <url> to connect to a central brand repo.
   ```
   Exit non-zero. Do not proceed.

2. Check if `.brand/voice.md` exists. If not:
   ```
   SKIP [voice] voice.md not found. Skipping voice audit.
   ```
   Exit non-zero (missing configuration is a setup issue).

### Determine the input

The argument can be either inline text or a file path:

- **Inline text** (no file extension, or quoted string that does not match an existing file): Audit the text directly.
- **File path** (matches an existing file, or has a known extension like `.txt`, `.md`, `.tsx`, `.jsx`, `.html`): Read the file and audit its text content.

### Process (follows `references/voice-guide.md`)

1. **Load voice rules**: Read `.brand/voice.md` (only this file — do not load DESIGN.md, colors.md, or typography.md). Extract:
   - Forbidden terms from the "Forbidden Terms" table (term + preferred alternative)
   - Tone spectrum rules (formality, warmth, directness for each context)
   - Grammar rules (case, voice, contractions, sentence length)

2. **Determine the context**: Classify the text based on the file type or content:
   - UI code files (`.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`): UI Microcopy context
   - Documentation files (`.md`, `.mdx`): Documentation context
   - Plain text files (`.txt`): Marketing context
   - Inline text (no file): Marketing context

3. **Scan for forbidden terms**: For each forbidden term from the voice guide:
   - Search **case-insensitively** through the text
   - Match exact words and substrings (e.g., "leveraging" contains "leverage")
   - For each match, record: the forbidden term, line number/position, full matched word

4. **Check tone rules**: Flag additional patterns:
   - Jargon density: 3+ jargon/buzzword-like terms in close proximity
   - Sentence length: Sentences exceeding 25 words
   - Passive voice: If active voice is required by grammar rules

5. **Provide replacements**: For each forbidden term violation, provide the preferred alternative from the voice guide. For tone rule violations, provide a plain-language suggestion.

6. **Report results**:

For each forbidden term violation (error):
```
ERROR [voice] line <N>: "<forbidden-term>" is a forbidden term. Use "<alternative>" instead.
```

For each tone rule violation (warning):
```
WARNING [voice] line <N>: <tone-issue-description>. Consider <suggestion>.
```

If zero violations:
```
PASS [voice] Text follows brand voice guidelines.
```

### Summary

After the audit, print a summary:
```
--- voice check summary ---
Forbidden terms: <N> violation(s)
Tone issues:    <M> warning(s)

Result: <PASS | FAIL (<X> error(s) to fix, <Y> warning(s) to review)>
```

Exit 0 if zero errors (warnings alone do not fail). Exit non-zero if any forbidden term violations exist.

## .petalrc Format

`.petalrc` is a YAML file at the project root. It records the brand source, current version, and project-level overrides.

```yaml
# .petalrc — Project brand configuration
brand:
  # The URL or path to the central brand repository
  source: github.com/company/brand

  # The version tag currently fetched (e.g., v1.2.0)
  version: v1.2.0

  # Project-level overrides. Non-null values are preserved during /petal update.
  # Null values inherit from the central brand on each update.
  # Keys are flattened dot-separated paths into .brand/ files.
  overrides:
    # Example: override the primary color for a campaign
    # colors.primary: "#FFD700"

    # Example: track but don't override the body font (inherits from central)
    # typography.body: null
```

### Override key conventions

Override keys use dot-separated paths that map to fields in `.brand/` markdown files:

| Key | Maps to | File |
|-----|---------|------|
| `colors.primary` | Primary hex value | `.brand/colors.md` |
| `colors.accent` | Accent hex value | `.brand/colors.md` |
| `typography.heading` | Heading font family | `.brand/typography.md` |
| `typography.body` | Body font family | `.brand/typography.md` |
| `typography.mono` | Mono font family | `.brand/typography.md` |
| `voice.terms` | Forbidden terms (merged) | `.brand/voice.md` |

### Value semantics

- **Non-null string**: This value is preserved during updates. The central brand's value for this key is ignored.
- **null**: This key is tracked but not overridden. The central brand's value flows through on each update.
