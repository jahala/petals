#!/usr/bin/env bash
# Spec: test/fixtures/sarif/petals-check.sarif.json is exactly what
# `petals gate` writes for one known change: an off-palette colour (error),
# an off-scale padding (warning) and placeholder copy in a mockup (note).
# plotplot keeps a copy as contracts/fixtures/sarif/petals-check.sarif.json;
# this spec keeps it equal to petals' real output. Prints TAP.
# Regenerate after a deliberate change with: bash tests/sarif-fixture.spec.sh --write
cd "$(dirname "$0")/.." || exit 1
PETALS="$PWD/petals/bin/petals"
FIX=test/fixtures/sarif/petals-check.sarif.json
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
R="$P/garden-bed"; mkdir -p "$R"
g() { git -C "$R" -c user.name=t -c user.email=t@t "$@"; }
g init -q -b main
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$R/.brand"
printf 'brand:\n  version: v1.9.0\nstages:\n  mockup:\n    - docs/designs/**\n' > "$R/.petalsrc"
g add -A && g commit -qm base
mkdir -p "$R/public" "$R/docs/designs"
printf '<p style="color:#3B82F6">Launch day.</p>\n<section style="padding:13px">Plots</section>\n' > "$R/public/index.html"
printf '<p>Lorem ipsum for the draft.</p>\n' > "$R/docs/designs/draft.html"
g add -A && g commit -qm change
(cd "$R" && "$PETALS" gate --base main~1 --format sarif) | python3 -I -c 'import json,sys; print(json.dumps(json.load(sys.stdin), indent=2, sort_keys=True))' > "$P/log.json"
if [ "${1:-}" = "--write" ]; then cp "$P/log.json" "$FIX"; echo "wrote $FIX"; exit 0; fi
levels=$(python3 -I -c 'import json,sys; print(" ".join(sorted(r["level"] for r in json.load(open(sys.argv[1]))["runs"][0]["results"])))' "$P/log.json")
[ "$levels" = "error note warning" ] && echo "ok - the known change gives one error, one warning and one note" || echo "not ok - the known change gives one error, one warning and one note ($levels)"
cmp -s "$P/log.json" "$FIX" && echo "ok - the committed fixture is petals' real output" || { echo "not ok - the committed fixture is petals' real output"; diff "$FIX" "$P/log.json" | head -10 | sed 's/^/# /'; exit 1; }
[ "$levels" = "error note warning" ] || exit 1
