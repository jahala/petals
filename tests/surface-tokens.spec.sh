#!/usr/bin/env bash
# Spec: border and outline widths must be stroke tokens, and a box-shadow must
# be a var(), none, or a documented recipe. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
cat > "$PROBE/surface.css" <<'CSS'
.a { border: 3px solid #E2D8C0; }
.b { border: 1px solid #E2D8C0; }
.c { border-bottom: 1.5px solid #E2D8C0; }
.d { outline: 4px solid #E2D8C0; }
.e { border-radius: 3px; border-width: 0; }
.f { box-shadow: 0 4px 12px rgba(58, 39, 24, 0.2); }
.g { box-shadow: var(--pp-shadow-lift); }
.h { box-shadow: 0 2px 4px rgba(58, 39, 24, 0.05), 0 14px 32px rgba(58, 39, 24, 0.08); }
.i { box-shadow: 0 2px 4px rgba(8, 6, 4, 0.05), 0 14px 32px rgba(8, 6, 4, 0.08); }
.j { box-shadow: none; outline: none; }
.k { box-shadow:inset 0 0 0 1.5px var(--pp-border); }
.l { box-shadow: inset 0 0 0 3px var(--bloom); }
CSS
out=$(bash "$SCRIPT" "$PROBE/surface.css" --brand "$BRAND" 2>&1)
t "a 3px border is off the stroke tokens" 'WARNING \[surface\] line 1: 3px border is off the stroke tokens' "$out"
n "a hairline border passes" 'line 2: .*stroke' "$out"
n "an emphasis border passes" 'line 3: .*stroke' "$out"
t "a 4px outline is off the stroke tokens" 'WARNING \[surface\] line 4: 4px outline is off the stroke tokens' "$out"
n "border-radius and a zero width are not strokes" 'line 5: .*stroke' "$out"
t "a made-up shadow warns" 'WARNING \[surface\] line 6: box-shadow matches no shadow recipe' "$out"
n "a shadow token reference passes" 'line 7: .*shadow' "$out"
n "a documented recipe written out passes" 'line 8: .*shadow' "$out"
n "the recipe's soil-night tint passes" 'line 9: .*shadow' "$out"
n "none is not a shadow or an outline" 'line 10:' "$out"
n "an inset ring at a stroke width is a stroke, not a shadow" 'line 11:' "$out"
t "an inset ring at an off-token width warns as a stroke" 'WARNING \[surface\] line 12: 3px ring is off the stroke tokens' "$out"
n "an inset ring is not judged as a shadow" 'line 12: box-shadow matches no shadow recipe' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
