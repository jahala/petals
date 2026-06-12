#!/usr/bin/env bash
# Spec for petals/scripts/check.sh — the deterministic core of /petals check.
# Run from the repo root: bash tests/check.spec.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BAD=test/fixtures/check/bad.css
GOOD=test/fixtures/check/good.css
fails=0
t() { # t <description> <grep-pattern> <output>
  if echo "$3" | grep -qE -e "$2"; then echo "PASS $1"; else echo "FAIL $1 — wanted /$2/"; fails=$((fails+1)); fi
}
[ -f "$SCRIPT" ] || { echo "FAIL check.sh does not exist"; exit 1; }

OUT_BAD=$(bash "$SCRIPT" "$BAD" --brand .brand 2>&1); RC_BAD=$?
OUT_GOOD=$(bash "$SCRIPT" "$GOOD" --brand .brand 2>&1); RC_GOOD=$?

t "off-palette hex is an error with a suggestion"  'ERROR \[color\] line 2: #3B82F6 is not in the palette\. Did you mean #' "$OUT_BAD"
t "low contrast pair under 3.0 is an error"        'ERROR \[color\].*#E8917F on #3F7A33 is 2\.1[0-9]:1' "$OUT_BAD"
t "contrast 3.0-4.5 band is a warning"             'WARNING \[color\].*#8A8A86 on #F8F5EC is 3\.1[0-9]:1' "$OUT_BAD"
t "13px off the 4px scale is a warning"            'WARNING \[layout\] line 3: 13px is outside the spacing scale\. Did you mean 12px' "$OUT_BAD"
t "undocumented breakpoint is a warning"           'WARNING \[layout\] line 10: 700px is not a documented breakpoint' "$OUT_BAD"
t "off-scale radius is a warning"                  'WARNING \[surface\] line 4: 9px is off the radius scale\. Did you mean 8px or 10px' "$OUT_BAD"
t "overshoot bezier is a warning"                  'WARNING \[surface\] line 5: cubic-bezier with overshoot' "$OUT_BAD"
t "pure-black shadow is a warning"                 'WARNING \[surface\] line 6: shadow uses pure black' "$OUT_BAD"
t "forbidden term is an error with replacement"    'ERROR \[voice\] line 9: "[Ss]upercharge" is a forbidden term\. Use "strengthen' "$OUT_BAD"
t "banned terminology synonym is a warning"        'WARNING \[voice\] line 9: "brand folder"' "$OUT_BAD"
t "capitalized product name is a warning"          'WARNING \[voice\] line 9: "Petals" — product names are lowercase' "$OUT_BAD"
t "summary block present"                          '--- petals check \(deterministic\) ---' "$OUT_BAD"
t "typography stays agent-side, stated"            'Typography: agent dimension' "$OUT_BAD"
t "bad file fails"                                 '^Result: FAIL' "$OUT_BAD"
[ "$RC_BAD" -ne 0 ] && echo "PASS bad exit code non-zero" || { echo "FAIL bad exit code"; fails=$((fails+1)); }
if echo "$OUT_GOOD" | grep -q '18px'; then echo "FAIL radius scan ignores width/height on the same line"; fails=$((fails+1)); else echo "PASS radius scan ignores width/height on the same line"; fi
if echo "$OUT_GOOD" | grep -qi 'supercharge'; then echo "FAIL quoted bad-example voice hits are skipped"; fails=$((fails+1)); else echo "PASS quoted bad-example voice hits are skipped"; fi
t "good file passes every dimension"               '^Result: PASS' "$OUT_GOOD"
[ "$RC_GOOD" -eq 0 ] && echo "PASS good exit code zero" || { echo "FAIL good exit code ($RC_GOOD): $OUT_GOOD"; fails=$((fails+1)); }
echo; echo "$fails failure(s)"; exit "$fails"
