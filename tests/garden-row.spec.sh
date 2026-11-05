#!/usr/bin/env bash
# Spec: a page's footer garden row lists exactly the brand's beds, in the
# brand's order (the reference row in components.md), each pill with its own
# bloom, and one current pill on a product page. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }

out=$(bash "$SCRIPT" test/fixtures/fonts/plotplot-ai.html --brand "$BRAND" 2>&1)
n "plotplot.ai's garden row matches the brand" 'garden row' "$out"
out=$(bash "$SCRIPT" test/fixtures/garden/reference-product-v1.8.0.html --brand "$BRAND" 2>&1)
t "a bed that left the garden is an error" 'ERROR \[surface\] line [0-9]+: the garden row lists "copeca"' "$out"
t "a planned tool listed as a bed is an error" 'ERROR \[surface\] line [0-9]+: the garden row lists "pollen"' "$out"
t "a missing bed is an error" 'ERROR \[surface\] line [0-9]+: the garden row is missing "mull"' "$out"

PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
row() { # row <current-name|""> <bloom-for-tend>
  echo '<div class="gf-plot"></div><nav class="gf-garden" aria-label="the garden">'
  for b in mull glean cultivate graft petals tend pleach umbel tilth mycelium weeder well; do
    bloom=$b; [ "$b" = tend ] && bloom=$2
    cur=""; [ "$b" = "$1" ] && cur=' class="is-current"'
    echo "<span style=\"--bloom:var(--pp-$bloom)\"$cur><span class=\"gf-dot\"></span>$b</span>"
  done
  echo '</nav>'
}
row petals tend > "$PROBE/ok.html"
out=$(bash "$SCRIPT" "$PROBE/ok.html" --brand "$BRAND" 2>&1)
n "a complete row with one current pill passes" 'garden row' "$out"
row petals petals > "$PROBE/bloom.html"
out=$(bash "$SCRIPT" "$PROBE/bloom.html" --brand "$BRAND" 2>&1)
t "a pill with another bed's bloom is an error" 'ERROR \[surface\] line 7: the garden row gives "tend" the bloom of "petals"' "$out"
row "" tend > "$PROBE/nocurrent.html"
out=$(bash "$SCRIPT" "$PROBE/nocurrent.html" --brand "$BRAND" 2>&1)
t "a product page with no current pill is an error" 'ERROR \[surface\] line [0-9]+: .*one current pill' "$out"
sed 's/<div class="gf-plot"><\/div>//' "$PROBE/nocurrent.html" > "$PROBE/umbrella.html"
out=$(bash "$SCRIPT" "$PROBE/umbrella.html" --brand "$BRAND" 2>&1)
n "the umbrella page needs no current pill" 'garden row' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
