# Petal at Scale — Central Brand, Distributed Projects

## The Problem

Company has 30 projects. Brand lives somewhere. When the brand updates, all 30 projects should reflect it. When an agent works on any project, it should get the current brand — not last year's copy that someone copy-pasted.

**But no server. No database. No API.**

---

## The Model: Git Is the Distribution Layer

```
┌─────────────────────────────────────────────┐
│  CENTRAL BRAND REPO                         │
│  github.com/company/brand                   │
│                                             │
│  .brand/                                    │
│  ├── identity.md        ← Brand team edits  │
│  ├── colors.md          ← these files when  │
│  ├── typography.md      ← the brand         │
│  ├── voice.md           ← changes           │
│  ├── brand.json                             │
│  └── assets/                                │
│      ├── logo-primary.svg                   │
│      └── ...                                │
│                                             │
│  Version: git tags (v1.0.0, v1.1.0, ...)   │
└────────────────────┬────────────────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   Project A    Project B    Project C
   (submodule)  (npm pkg)   (curl in CI)
```

Projects consume the brand. Three consumption patterns, same `.brand/` output.

---

## Three Consumption Patterns

### Pattern A: Git Submodule (Best for dev teams)

```bash
# In each project:
git submodule add git@github.com:company/brand.git .brand
git submodule update --remote  # when brand updates
```

```
project-a/
├── .brand/ → github.com/company/brand (v1.2.0)
├── src/
└── ...
```

**Advantages:** Always in sync with `git pull`. Version-pinned. Works offline.
**Tradeoff:** Requires everyone to understand submodules.

### Pattern B: npm/npx Package (Best for JS/TS projects)

```bash
# Central brand is published as an npm package:
npm install @company/brand --save-dev

# .brand/ lives in node_modules/@company/brand/.brand/
# Or petal copies it to project root on install
```

```json
// package.json
{
  "devDependencies": {
    "@company/brand": "^1.2.0"
  }
}
```

**Advantages:** Familiar tooling. Semver. Dependabot auto-updates.
**Tradeoff:** Node-specific. Extra step to publish on brand change.

### Pattern C: curl/wget in CI (Works everywhere)

```yaml
# .github/workflows/brand-check.yml
- name: Fetch latest brand
  run: |
    curl -sSL https://raw.githubusercontent.com/company/brand/main/brand.json -o .brand/brand.json
    curl -sSL https://raw.githubusercontent.com/company/brand/main/colors.md -o .brand/colors.md
```

**Advantages:** Zero dependencies. Works in any CI.
**Tradeoff:** Manual sync. No local offline brand.

### Recommendation: Support all three. Default to git submodule.

---

## How Petal Works in This Model

### `/petal init` — Two modes

```bash
# Mode 1: Create a NEW central brand from assets
/petal init ./brand-assets/ --output .brand/
# → Creates .brand/ with all files
# → This IS the central brand repo

# Mode 2: Pull brand FROM central repo INTO a project
/petal init --from github.com/company/brand
# → Clones/submodules/adds npm dependency
# → Ensures .brand/ is available in this project
```

### `/petal update` — Sync with central

```bash
/petal update
# → git submodule update --remote (if submodule)
# → npm update @company/brand (if npm package)
# → curl latest (if URL-based)
# → Tells agent: "Brand updated from v1.2.0 → v1.3.0. Changes: primary color #E7000B → #FF1A2B, new font: Cabinet Grotesk"
```

### `/petal check` — Now version-aware

```bash
/petal check landing.tsx
# → Checks against current .brand/
# → Also reports: "This project uses brand v1.2.0. Latest is v1.3.0. 23 days behind."
```

---

## What Happens When the Brand Updates?

```
Brand team updates central repo:
  github.com/company/brand
  → Edit colors.md: primary changes from #E7000B to #FF1A2B
  → Commit: "Rebrand: warmer red, cabinet grotesk heading"
  → Tag: v1.3.0

Petal notification flow:
  
  1. Project agent starts work
  2. Petal detects .brand/ is behind central
     (git submodule: git fetch → sees new tag)
     (npm: npm outdated @company/brand)
  3. Agent gets warning:
     "⚠️ Brand is 3 versions behind (v1.0.2 → v1.3.0).
      Changes include: primary color shift, new heading font, 
      updated voice guidelines.
      Run /petal update to sync."
  4. Agent decides: update now or finish current work first
```

**No push. No webhooks. No server.** Git is the notification system. `git fetch` costs nothing.

---

## Project-Level Brand Overrides

Some projects legitimately diverge. A marketing microsite might use a campaign palette. A product dashboard might have stricter spacing.

```yaml
# .brand/overrides.yaml (project-specific, gitignored from central)
colors:
  primary: "#custom-hex"        # Override central primary
  accent: null                  # null = inherit from central

typography:
  heading: "CustomFont"         # Override, project-specific constraint

voice:
  formality: "casual"           # More casual than corporate
```

```
Resolution order:
  1. Project override (if exists)
  2. Central brand
```

Petal merges. `null` = fall through to central. This means:
- 95% of values come from central brand
- A project can customize 1-2 things without forking the whole brand
- Central updates STILL flow through for everything not overridden

---

## Security and Access

For public brands → public repo. Done.

For private brands:

| Consumption Pattern | Auth Model |
|---------------------|-----------|
| Git submodule | SSH keys or GitHub App tokens. Already how devs access private repos. |
| npm package | npm registry auth token (GitHub Packages, npm private) |
| curl in CI | GitHub PAT in CI secrets |

No new auth system. Petal uses whichever auth the developer already has for their git/npm.

---

## What Petal Does NOT Do

| Not petal's job | Why |
|-----------------|-----|
| Host the brand | GitHub/GitLab/etc hosts it. Petal just reads and writes files. |
| Push updates to projects | Git does this. Petal tells you you're behind. |
| Auth | Developer already has git/npm auth. Petal uses existing credentials. |
| Real-time sync | Nothing is real-time with files. `git fetch` + `/petal update` is fast enough. |
| Enforce updates | Petal warns. Teams decide when to update. Some projects might intentionally lag. |

---

## Summary

```
Central brand repo (git) 
    → consumed by projects (submodule / npm / curl)
    → petal reads .brand/ in each project
    → petal warns when .brand/ is behind central
    → project overrides for legitimate divergences
    → git is the sync mechanism
    → zero new infrastructure
```

The central brand IS a git repo. The `.brand/` folder IS the API. Petal is the tool that creates it, reads it, checks against it, and warns when it's stale.

No servers. No databases. No webhooks. Just files and git.
