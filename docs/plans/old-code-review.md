# Old-code review, 2026-11-05

_Issue numbers marked “archive” refer to the private repository petals was built in before it went public._

Phase 0 of the [roadmap](2026-11-05-petals-roadmap.md) asked for a verdict on each piece of
petals before building on it: port it, learn from it, or drop it, with a reason. The facts came
from reading each script, running its spec, and probing the defects by hand. The newest code was
the unlanded `petals-release` working tree (June 2026), so that is what was judged and landed.

A verdict of **port** means the code lands on master and stays the foundation. **Learn from**
means it lands but is not trusted or wired in until its issue is fixed. **Drop** means it is
removed.

## Scripts

| Script | Verdict | Reason |
|---|---|---|
| `scripts/check.sh` | port | The deterministic engine is the product's core, and its 23-case spec passes. Fixed in this landing: correctly lowercase product names no longer warn (#3), and relative paths resolve from the caller. Open: archive #8 to archive #15, archive #25, #13. |
| `scripts/check.sh --fix` | drop | No doc named it and no test covered it. It rewrote lines with sed, its counter ran in a subshell and was never read, and it printed "Auto-fix applied." even when nothing changed. The fixer archive #9 asks for is a different, narrower tool. |
| `scripts/check.sh --json` | drop | No doc named it. archive #6 replaced it with `--format sarif`, the garden's findings format. |
| `scripts/fetch-brand.sh` | port | It fetched plotplot v1.9.0 for this landing (git strategy) and its spec passes. Fixed: relative source and target paths. Open: #12 (target never cleared, incomplete raw fallback, untested strategies). |
| `scripts/apply-overrides.sh` | learn from | It reports overrides as applied when nothing changed, and its patterns miss the real brand's tables (#11). It stays unwired from the `update` workflow until #11 holds. |
| `scripts/check-brand-drift.sh` | port | It reports this repository as current at v1.9.0. Fixed: a `local` outside a function stopped config mode for GitHub sources; shellcheck now guards that class. Now wired into SKILL.md's drift workflow, which described the same logic as prose. |
| `scripts/export-tokens.sh` | port | It derives `tokens.css` and `tokens.json` from the markdown, which is half of archive #10. Fixed: work files now live in a folder the run removes on any exit. Open: the `--check` mode in archive #10. |
| `scripts/fix-typography.sh` | port | New with archive #9, after this review: writes `html{font-synthesis:none}` into a page so faux bold and italic stop without hand-collecting selectors. Its spec is `tests/faux-style.spec.sh`. |
| `scripts/lint-skills.sh` | port | New with archive #7, after this review: fails a skill the harness would drop without a word (no description, a name that differs from its directory, or no always-on instruction naming it). Its spec is `tests/skill-lint.spec.sh`. |
| `scripts/marks.py` | port | Ported from plotplot's v1.9.0 `scripts/marks.py` for issue archive #17: its outputs stay byte-identical, but the beds, the line marks, the blooms, the inks and the drawing rules now come from the brand folder instead of lists in the script. Its spec is `tests/marks.spec.sh`. |
| `scripts/vendor.sh` | port | New with archive #23, after this review: copies petals into another repository with a stamp (commit, tag, a checksum per file), and `--check` fails when that copy is not the version it names. Its spec is `tests/vendor.spec.sh`. |
| `scripts/review.sh` | port | New with archive #20, after this review: serves pages for the owner to look at in their browser, with an index in the brand, and stops leaving nothing behind. Its spec is `tests/review.spec.sh`. |
| `scripts/try-font.sh` | drop | Removed on 2026-11-05 with the owner's yes: trying a heading face happens about once per brand, and its one lasting rule lives in the check and `fix-typography.sh`. SKILL.md keeps it as a recipe. |
| `scripts/lib/common.sh` | port | Root discovery lets the scripts run from anywhere in a project. Fixed: it records the caller's directory, so typed paths keep their meaning after the move to the root, and the scripts refuse to run without it instead of silently skipping it. |

## SKILL.md workflows

| Workflow | Verdict | Reason |
|---|---|---|
| `init <folder>` | port | Extraction is prose the agent follows with its own tools, by design. Its fixtures exist; a spec that uses them is open work for the brand-extraction loop. |
| `init --from` | port | Backed by `fetch-brand.sh`. Now documents the product-layer `.gitignore` for a product in a family brand. |
| `update` | port | Backed by `fetch-brand.sh` and `export-tokens.sh`. Fixed: the swap step no longer deletes a committed product layer. Step 6 stays prose until #11. |
| `check` (drift) | port | Now runs `check-brand-drift.sh` instead of describing it. |
| `check <file>` | port | Runs `check.sh`, then the agent covers typography and tone. |
| `voice <text>` | port | Tone needs judgment, so it stays an agent workflow; the forbidden-term part is in `check.sh`. |
| `color <name>` | port | A lookup in `colors.md`; nothing to script. |
| `token <format>` | port | Fixed: the table no longer claims a tailwind format nothing produces. |
| `logo [variant]` | port | Fixed: it pointed at a `logo.svg` that no longer exists; it now resolves the product's or the umbrella's mark files. |
| `book` | learn from | The book is written by the agent, so nothing derives it and CI cannot check it. Its specs report unevaluable when no book was generated. A scripted book belongs with derive-tokens. |
| `review <page>` | port | New with archive #20, after this review: backed by `scripts/review.sh`; the owner looks at pages in their browser and the stop leaves nothing behind. |
| `try font` | drop | Removed on 2026-11-05: a once-per-brand task is a recipe in SKILL.md, not a command. |
| Guardrail recipes | port | Copy-paste recipes for now; #10 turns the hook into an installer, and #4 replaces the CI recipe with the stem. |
| Init step "the skill travels with the project" | drop | It told the agent to copy `petals/` into each project, which contradicts "never duplicate the scripts into projects". The README quickstart said the same and now links the skill once instead. |

## How the repository holds its brand now

plotplot's own convention (its `petalsrc.example` for each bed) applies: petals commits its product
layer at `.brand/products/petals/` and ignores the rest of `.brand/`, which `fetch-brand.sh` fills
from jahala/plotplot at the tag `.petalsrc` pins (v1.9.0). The specs no longer read that cache:
`check.sh` and `export-tokens.sh` are tested against a frozen copy of the brand they were written
for, at `test/fixtures/brand-plotplot-v2.0.0/`, so a brand update never breaks a test.

## Left out of the landing

- `docs/tend/` edits: already carried into the tend2 map by archive #34.
- `.githooks/`: the weeder guard's hooks bake one machine's home path into each file (jahala/weeder#84), so they stay local.
- `.DS_Store` files: untracked from now on.
- `.brand/products/petals/assets/logo.svg`: the old fan mark, replaced by the umbrella's `petals-mark.svg` and `petals-mark-night.svg` at v1.9.0.
- The working tree's `.brand/` (v2.0.0 from a local path that no longer exists): kept only as the frozen test fixture.
