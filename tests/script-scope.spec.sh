#!/usr/bin/env bash
# Spec: in an HTML page, a <script> block is program data, not styling. Its
# colours (a canvas gradient stop, a fillStyle string) and its object literals
# are not judged by the CSS rules (issue #74, plotplot.ai's garden film). Style
# blocks and style attributes beside it stay judged, and a file that is all
# script (.tsx) keeps being judged. Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-template/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1, wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1, did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
cat > "$P/film.html" <<'HTML'
<style>.a { color: #ff00aa; }</style>
<script>
const grd = ctx.createLinearGradient(0, 0, 0, 9);
grd.addColorStop(0, 'rgba(0,0,0,0.34)');
ctx.fillStyle = '#ff00aa';
const theme = { color: '#ffffff', background: '#fffffe' };
</script>
<p style="color: #ff00aa">styled</p>
<script src="kit.js"></script><div style="background: #ff00aa">x</div>
HTML
out=$(bash "$SCRIPT" "$P/film.html" --brand "$BRAND" 2>&1)
t "a colour in a style block beside a script is still judged" 'ERROR \[color\] line 1: #ff00aa' "$out"
n "a canvas gradient stop in a script is not judged" 'line 4:' "$out"
n "a fillStyle string in a script is not judged" 'line 5:' "$out"
n "an object literal in a script is not a contrast pair" 'line 6:' "$out"
t "a style attribute after the script is still judged" 'ERROR \[color\] line 8: #ff00aa' "$out"
t "a style attribute after a one-line script tag is still judged" 'ERROR \[color\] line 9: #ff00aa' "$out"
printf 'export const A = () => <p style={{ color: "#ff00aa" }}>x</p>;\n' > "$P/a.tsx"
out=$(bash "$SCRIPT" "$P/a.tsx" --brand "$BRAND" 2>&1)
t "a .tsx file, all script, is still judged" 'ERROR \[color\] line 1: #ff00aa' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
