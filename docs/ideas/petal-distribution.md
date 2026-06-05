# Petal — Distribution Design (Final)

## The Model

```
Central brand repo (github.com/company/brand, private or public)
        │
        │  Petal fetches from here
        ▼
Project .brand/  (gitignored — it's a cache, not source)
```

## How Projects Connect

Each project declares where its brand lives:

```yaml
# .petalrc (at project root) — or in CLAUDE.md
brand:
  source: github.com/company/brand   # or git@github.com:company/brand.git
  version: latest                     # or pin to a tag: v1.2.0
```

No config needed if there's only one obvious source. Petal finds it.

## How Fetching Works

### Default: HTTPS fetch (works everywhere, zero setup)

```
/petal update

→ curl -s https://raw.githubusercontent.com/company/brand/main/.brand/colors.md -o .brand/colors.md
→ curl -s https://raw.githubusercontent.com/company/brand/main/.brand/voice.md -o .brand/voice.md
→ ... repeat for all brand files
→ curl -s https://raw.githubusercontent.com/company/brand/main/.brand/assets/logo.svg -o .brand/assets/logo.svg
```

**Private repos?** Developer already has `GITHUB_TOKEN` or `GH_TOKEN` in their environment (for `gh` CLI, npm, etc). Petal uses it.

```bash
# Private repo fetch — same thing, with auth header
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  -s https://api.github.com/repos/company/brand/contents/.brand/colors.md \
  | jq -r '.content' | base64 -d > .brand/colors.md
```

### Alternative: `git clone --depth 1` (when you want the whole thing at once)

```
/petal update

→ git clone --depth 1 git@github.com:company/brand.git /tmp/brand-XXXXX
→ cp -r /tmp/brand-XXXXX/.brand/* .brand/
→ rm -rf /tmp/brand-XXXXX
```

Shallow clone, copy the `.brand/` directory, delete the temp clone. Fast, uses SSH for private repos.

### Petal picks the best method automatically:

1. Has `git` and SSH key? → shallow clone
2. Has `GITHUB_TOKEN` env? → HTTPS API fetch
3. Public repo? → raw.githubusercontent.com

## Brand Updates — How They Reach Projects

```
1. Brand team edits colors.md in central repo, tags v1.4.0
2. Nothing happens immediately. No push, no webhook, no notification.
3. Next time an agent starts work on ANY project:
   a. /petal check runs (or agent just reads .brand/identity.md)
   b. Petal compares local .brand/ version hash with central
   c. If behind: "⚠ Brand has updated (v1.3 → v1.4). Primary color changed.
      Run /petal update."
4. Agent updates (now or after current task)
5. Brand flows into next work
```

## .brand/ Is Gitignored

```
# .gitignore
.brand/
```

It's a cache. Derived from central. Not source code. Not committed.

If a project NEEDS to commit brand files (for CI that can't fetch), you CAN. Petal doesn't care. It just reads whatever's there.

## Project Overrides

```yaml
# .petalrc
brand:
  source: github.com/company/brand
  overrides:
    colors:
      primary: "#custom-only-for-this-project"
```

Overrides live in `.petalrc`. Central brand flows through for everything not overridden. Petal merges them at read time. The agent sees the merged result.

---

## What Petal Does

| Command | What happens |
|---------|-------------|
| `/petal init /path/to/assets` | Creates a brand from scratch. Outputs `.brand/`. This BECOMES the central repo. |
| `/petal init --from github.com/company/brand` | Pulls brand into a project. Creates `.petalrc` with source URL. Runs first fetch. |
| `/petal update` | Fetches latest from central. Merges with project overrides. |
| `/petal check` | Reads current `.brand/`, compares version with central, reports drift + compliance. |
| `/petal check file.tsx` | Audits file against current brand. |
| `/petal voice "tagline text"` | Checks text against voice rules. |
| `/petal color primary` | Returns the resolved primary color (central + overrides merged). |
