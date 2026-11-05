#!/usr/bin/env bash
# Spec: the voice rules judge copy, as whole words. A banned synonym does not
# fire inside a longer word ("bot" in "bottom") or a domain ("ai" in
# "plotplot.ai"); code, quoted output, styles and scripts are not copy. Found
# by checking petals' own landing page. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
mkdir -p "$P/.brand"; cp -R "$BRAND/." "$P/.brand/"
mkdir -p "$P/.brand/products/petals"
printf '# petals: voice delta\n\n## Terminology\n\n| Use | Not | Why |\n|-----|-----|-----|\n| skill | bot | what petals is |\n| agent | AI | who reads it |\n| extract | import | explicit-only |\n' > "$P/.brand/products/petals/voice.md"
cat > "$P/page.html" <<'HTML'
<style>
  .tape::after { bottom: -6px; color: red !important; }
</style>
<p>The sticker sits at the bottom of the plotplot.ai page.</p>
<p>Write <code>Petals-allow: color/off-palette approved</code> on the commit.</p>
<p>This bot reads the brand.</p>
<p>Our AI picks the colours.</p>
<p>You import the guidelines.</p>
<p>Petals reads the brand.</p>
<script>var bot = 1;</script>
HTML
out=$(bash "$SCRIPT" "$P/page.html" --brand "$P/.brand" --product petals 2>&1)
n "a synonym inside a longer word does not fire (bottom, important)" 'line (2|4): "(bot|import)' "$out"
n "a synonym inside a domain does not fire (plotplot.ai)" 'line 4: "ai"' "$out"
n "code is not copy (a trailer's real name)" 'line 5:' "$out"
n "scripts are not copy" 'line 10:' "$out"
t "a whole-word synonym in copy still warns (bot)" 'WARNING \[voice\] line 6: "bot"' "$out"
t "a whole-word synonym in copy still warns (AI)" 'WARNING \[voice\] line 7: "ai"' "$out"
t "a whole-word synonym in copy still warns (import)" 'WARNING \[voice\] line 8: "import"' "$out"
t "a capitalised product name in copy still warns" 'WARNING \[voice\] line 9: "Petals"' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
