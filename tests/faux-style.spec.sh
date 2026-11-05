#!/usr/bin/env bash
# Spec: check.sh flags a rule that asks a face for a weight or style it does
# not have, so the browser fakes it, unless font-synthesis: none covers the
# page; fix-typography.sh writes that override. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
FIX=petals/scripts/fix-typography.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
FX=test/fixtures/typography
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }

out=$(bash "$SCRIPT" "$FX/reference-product-v1.7.0.html" --brand "$BRAND" 2>&1)
t "v1.7.0 page: the heading face is asked for a weight it lacks" 'ERROR \[typography\] line [0-9]+: .*"Protest Riot" has no weight 520' "$out"
out=$(bash "$SCRIPT" "$FX/reference-product-v1.9.0.html" --brand "$BRAND" 2>&1)
n "v1.9.0 page: font-synthesis none covers it" 'has no (weight|italic)' "$out"

PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
cat > "$PROBE/rules.css" <<'CSS'
/* a stray } and { in a comment must not become a selector */
.a { font-family: "Hanken Grotesk"; font-weight: 800; }
.b { font-family: "Hanken Grotesk"; font-weight: 600; }
.c { font-family: var(--pp-font-heading); font-style: italic; }
h2 { font-family: var(--font-heading); }
.d {
  font-family: 'Protest Riot', Georgia, serif;
  font-weight: 400;
}
@media (min-width: 880px) { .e { font-family: "JetBrains Mono"; font-weight: bold; } }
CSS
out=$(bash "$SCRIPT" "$PROBE/rules.css" --brand "$BRAND" 2>&1)
n "a comment's braces do not become a rule" 'line 1:.*has no' "$out"
t "a weight the face lacks is an error" 'ERROR \[typography\] line 2: "Hanken Grotesk" has no weight 800' "$out"
n "a weight the face has passes" 'line 3:.*has no' "$out"
t "italic on a face without italic is an error" 'ERROR \[typography\] line 4: "Protest Riot" has no italic' "$out"
t "a heading's default bold on a one-weight face is an error" 'ERROR \[typography\] line 5: "Protest Riot" has no weight 700' "$out"
n "a multi-line rule with a weight the face has passes" 'line 6:.*has no' "$out"
n "bold inside @media on a face with 700 passes" 'line 10:.*has no' "$out"

cp "$FX/reference-product-v1.7.0.html" "$PROBE/page.html"
bash "$FIX" "$PROBE/page.html" >/dev/null 2>&1
out=$(bash "$SCRIPT" "$PROBE/page.html" --brand "$BRAND" 2>&1)
n "after the fixer the faux findings are gone" 'has no (weight|italic)' "$out"
bash "$FIX" "$PROBE/page.html" >/dev/null 2>&1
t "the fixer is idempotent" '^1$' "$(grep -c 'font-synthesis:none' "$PROBE/page.html")"
echo; echo "$fails failure(s)"; exit "$fails"
