#!/usr/bin/env bash
# Spec: check.sh reads hex colours only in colour positions.
# Anchors, ids, sources and text content are not colours. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
cat > "$PROBE/page.html" <<'HTML'
<a href="#beds">the beds</a>
<div id="fed" class="#cab"><img src="#add"></div>
<p>Ticket #bad and #deed stay words.</p>
#bee in a paragraph that wraps onto its own line
<p style="color:#123456">styled</p>
<svg><rect fill="#abcdef"/></svg>
<style>
.x { color: #fedcba; }
</style>
HTML
out=$(bash "$SCRIPT" "$PROBE/page.html" --brand "$BRAND" 2>&1)
n "an href anchor is not a colour" 'line 1: #bed' "$out"
n "id, class and src values are not colours" 'line 2: #' "$out"
n "text content is not a colour" 'line 3: #' "$out"
n "wrapped text content is not a colour" 'line 4: #' "$out"
t "a style attribute colour is still judged" 'ERROR \[color\] line 5: #123456' "$out"
t "a fill attribute colour is still judged" 'ERROR \[color\] line 6: #abcdef' "$out"
t "a colour in a style block is still judged" 'ERROR \[color\] line 8: #fedcba' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
