# petals architecture

petals carries a brand into what agents build and checks what came out. It is
a skill (markdown an agent reads) plus deterministic scripts (bash, awk and
python3, no other dependencies). The plan of record is
[the roadmap](plans/2026-11-05-petals-roadmap.md); the map is `docs/tend2/`.

## Components

| Piece | Where | What it does |
|---|---|---|
| The skill | `petals/SKILL.md`, `references/`, `templates/` | Tells the agent when to read the brand and how to work inside it. |
| The check | `petals/scripts/check.sh` | Judges one file against a brand: colour, layout, surface, voice, typography families, content. Text or SARIF 2.1.0. |
| The entry point | `petals/bin/petals` | `check` (one file), `gate` (a change, one SARIF log), `guard <hook>` (commit time). |
| Brand plumbing | `fetch-brand.sh`, `check-brand-drift.sh`, `apply-overrides.sh`, `export-tokens.sh`, `marks.py` | Fetch the brand, report drift, derive tokens and night marks from the markdown. |
| Inventing a brand | `new-brand.py` | `system` turns one direction request into a full system as JSON on stdout: light and dark palettes, the contrast pairs to document, the scales, and a receipt. Its contrast arithmetic is check.sh's, and `tests/directions.spec.sh` compares the two. It writes no files ([the plan](plans/2026-11-11-invent-a-brand.md)). |
| Distribution | `vendor.sh`, `scripts/build-release.sh`, `garden.json` | A stamped copy for another repository; the release the plotplot stem plants; the bed's manifest. |

## How a judgment flows

1. The brand is markdown under `.brand/`. A product in a family brand commits
   its own layer (`.brand/products/<product>/`) and fetches the umbrella's
   files from the brand repository pinned in `.petalsrc`.
2. `check.sh` reads the brand's tables and CSS blocks and judges a file line by
   line. The format is the one `petals/templates/` writes. The token prefix
   is the one colors.md's CSS block declares, read for every script by
   `brand_prefix` in `lib/common.sh` (`tests/template-brand.spec.sh`). The
   dark theme's selector is the one colors.md's CSS block gives it
   (`[data-theme="dark"]`, `.dark`, `:root` inside a dark media query),
   read by `brand_dark_selector` there (`tests/dark-selector.spec.sh`). Every
   rule has one id, `<dimension>/<rule>`, declared in the SARIF driver; the
   control page (`test/fixtures/control/`) trips every one.
3. `petals gate` lists the files a change touches, takes the config and the
   brand as the base carries them (never the change's copy), runs the check on
   each and merges one SARIF log. `Petals-allow: <rule> <reason>` trailers turn
   a finding into a note that carries its reason.
4. The plotplot stem calls `petals gate --format sarif` on pull requests and
   `petals guard <hook>` from its planted git hooks.

## Stores and their lifetimes

| Store | Keeps | For how long | What removes the rest |
|---|---|---|---|
| `.brand/` (umbrella files) | The fetched brand at the pinned version | Until the next fetch | `fetch-brand.sh` overlays the new version, but never a file git tracks there (the project's own layer); the fetched files are gitignored |
| `.brand/products/<product>/` | The product's own layer | As long as the product | Edited in git like source |
| `.brand/tokens.css`, `tokens.json` | Tokens derived from the markdown | Until the markdown changes | `export-tokens.sh` rewrites them; `--check` fails when they drift |
| `*-mark-night.svg` | Night marks derived from the paper marks | Until a paper mark changes | `marks.py` rewrites them; `--check` fails when they drift |
| `<repo>/petals/` and its `VERSION` | A vendored copy of petals at one commit | Until the next `vendor.sh` run | `vendor.sh` syncs the copy, removing files petals no longer ships |
| Release cache | The unpacked release: `<repo>/.plotplot/cache/petals/<sha>/` when planted by the stem, else `${XDG_CACHE_HOME:-~/.cache}/petals/<sha>/` | The current version's copy only | The first run of a new version hands every older copy to `trash`; without `trash` it names them on stderr and leaves them |
| `.petals-review/` | The review index and the server's pid, port and log | While a review runs | `petals review --stop` ends the server and hands the folder to `trash` (without trash it names it); git's `info/exclude` keeps it out of commits, in a worktree too |
| Scratch folders | Work files of one run (gate, export, vendor, specs) | That run | The run's own trap removes them, also on failure |
| `test/fixtures/` | Frozen real pages and brands, each with a `SOURCES.md` | As long as a spec reads them | Removed with the spec that reads them |

No store is shared state between requests: every run opens its own scratch
folder. Deletion follows the owner's rule: `trash`, never `rm`, except a temp
folder the same run created.

## Runtime dependencies

bash (3.2 or later), awk, python3, git, and for releases base64 and tar.
`garden.json` lists them under `flagged`.
