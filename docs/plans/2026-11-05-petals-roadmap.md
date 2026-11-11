# petals roadmap, from 2026-11-05

_Issue numbers marked “archive” refer to the private repository petals was built in before it went public._

## Goal

petals does a brand's mechanical work, so people spend their time on design.
When a project has a brand, petals reads it and holds every agent to it.
When a project has none, petals invents one, components included, and then
holds every agent to that. The check runs on every commit and pull request
through the plotplot stem, next to weeder.

## Decisions this plan rests on

- **No brand means petals invents one** (owner, 2026-11-05). A generated brand
  is a normal brand: the same `.brand/` files, tokens, book and check. Every
  generated value is marked, so the owner can replace it. A brand that exists
  is only ever read, never overridden.
- **Components are part of the brand.** Each component has one home, and a
  contract names its home, its states and its tokens. The check flags a
  component that is rebuilt instead of reused.
- **petals is a planted bed under the stem.** `plotplot check --strict` is the
  one gate for hooks and pull requests. petals ships a `garden.json` manifest
  and a SARIF check, and gets no CI gate of its own. Brand and component rules
  live in petals only. Code-honesty rules stay in weeder.
- **The seam with graft is the control kind.** graft names each screen's
  controls and their kinds (action, input, toggle, link). petals maps each
  kind to a component contract. Each tool keeps its own facts.
- **Files have a stage.** Mockup paths are declared in config, and everything
  else is production. Content-truth rules (placeholders, invented testimonials,
  invented numbers) are notes in a mockup and block in production. Brand rules
  are strict in both. A mockup file that reaches a production path or a
  publish is blocked.

## Where petals stands

- All five spec suites pass on the working tree.
- The working tree on `petals-release` holds unlanded work: 49 changed files,
  including a 418-line `check.sh` (262 on master) and an untracked
  `export-tokens.sh`. Some of it may already answer open issues, such as archive #10.
- 18 issues are open (archive #6 to archive #23).
- The 2026-07-20 audit findings are still live. The landing page fails its
  own check (52 errors), the book is stale, `.petalsrc` points at a local
  path, the product-name casing rule warns on correct lowercase names, and
  the surface audit skips stroke widths and shadow recipes.

## The order

Every item lands on its own, on green, with its failing test written first.
Each known case comes from real pages copied into fixtures, with their source
and date recorded. Each phase ends with its exit check passing.

### Phase 0: ground

1. Land or drop the unlanded working tree, decided file by file and
   recorded. Nothing in it is lost silently.
2. Review the old code (check, fetch, overrides, drift, export and the SKILL
   workflows), and decide port, learn from or drop for each, with a reason.
   The `--fix` mode gets its decision here.
3. Write `AGENTS.md`, and give petals a tend page: who it is for, their pain,
   what petals is now, and the current goal.
4. Point `.petalsrc` at jahala/plotplot, tag v1.9.0.

Exit: master holds everything worth keeping, and the tend map names each
phase below as a feature.

### Phase 1: stop false passes

archive #8 fonts, archive #9 faux bold and italic, archive #12 anchors read as colours, archive #11 contrast
in both themes, archive #13 hairline spacing, archive #14 em dashes, archive #15 the garden row. Then
two new issues from the audit: invert the casing rule, and check stroke
widths and shadow recipes. Then archive #6 SARIF and archive #7 skill lint.

Exit: the five live bed pages fail on fonts, and plotplot.ai passes. A control
page built by hand with known violations fails on each one. (petals' own
landing page moved to phase 7: passing honestly means rebuilding it from the
brand's reference with archive #21, not patching colours into the old design.)

### Phase 2: derive, never hand-edit

archive #10 tokens derived from the markdown, with a `--check` mode. archive #17 marks.py
moves into petals. archive #23 a version stamp for the copy in jahala/plotplot.

Exit: a changed markdown value with stale tokens fails `--check`.

### Phase 3: petals as a planted bed

1. `garden.json` with the check face (SARIF) and the hooks petals wants.
2. Releases with a sha256 per platform, and an entry in the umbrella's
   `garden.lock` template (landed by plotplot).
3. Weeder's habits: rules that are clear-cut block and the rest warn, an
   allow trailer with a reason, SARIF suppressions, and config read from the
   base branch.
4. Stages: mockup paths in config, production by default, and the boundary
   checks.
5. A test workflow for petals' own spec suites.

Exit: a planted repository's pull request shows petals findings inside the
one `plotplot check` SARIF log.

### Phase 4: the owner's review loop

archive #20 `/petals review`. (archive #19 `/petals try font` was cut on 2026-11-05: a once-per-brand task, now a recipe in SKILL.md.) The bootstrap in phase 5
shows its options through these.

Exit: one command opens a draft in the owner's browser and stops cleanly,
leaving nothing behind.

### Phase 5: invent a brand when none exists

Planned in detail in [2026-11-11-invent-a-brand.md](2026-11-11-invent-a-brand.md).

1. `/petals init --new`: an interview of at most three questions a round,
   with "undecided" recorded instead of invented.
2. Starter presets in petals' own format, contrast-checked at generation.
   Three are dealt from a history file, so projects do not converge. The owner
   picks one through the review loop.
3. Starter components (button, input, checkbox, radio, toggle, select,
   link) written as real code in the project. Each has a contract in
   `.brand/components/<name>.md` and a preview page that forces every state.
4. The reuse check: a raw control in a file that does not import its
   component, or a second definition outside the component's home, is
   flagged. A graft control kind with no matching component is flagged too.

Exit: the kill test below.

### Phase 6: the generic-look rule pack

Source-level rules with ids, a tell and a fix per finding, and a level per
stage. The brand can switch any rule off. Then an installer for the
edit-time hook.

Exit: one fixture per rule fails, and its clean twin passes.

### Phase 7: the family and new pages

#1 the family report and #2 `/petals change <dimension>`. Product frames
 and the bed page builder were cut to recipes in SKILL.md on
2026-11-05; petals' own landing page is rebuilt from the reference by hand.

Exit: archive #21 reproduces the settled drafts' brand values.

## Kill test for phases 5 and 6

Bootstrap two fresh projects. Separate agent sessions build three pages in
each. The plan has failed if any of these happens:

- a rebuilt component or an off-token value passes the check;
- the two projects look alike;
- the hand-built control page passes.

## Order rationale

Phase 1 comes first because a generated brand judged by a check that passes
wrong pages proves nothing. Phase 3 comes early because the font drift across
the beds went unnoticed for nine days, since nothing ran the check on commit.
Phases 4 and 2 are what phase 5 is built on. Phase 7 moves after the new work
because the gate in phase 3 already stops most family drift at commit time.
