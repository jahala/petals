#!/usr/bin/env bash
# Spec: contrast is judged once per theme: the :root values, then the dark
# overrides on top, and a finding names its theme. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/check.sh
BRAND=test/fixtures/brand-plotplot-v1.9.0/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
PROBE=$(mktemp -d); trap 'rm -rf "$PROBE"' EXIT
cat > "$PROBE/themes.css" <<'CSS'
:root { --x: #E8E8E8; }
[data-theme="dark"] { --x: #000000; }
.t { color: var(--x); background: #FAF5E9; }
:root{--y:#E8E8E8}[data-theme="dark"]{--y:#000000}
.u { color: var(--y); background: #FAF5E9; }
CSS
out=$(bash "$SCRIPT" "$PROBE/themes.css" --brand "$BRAND" 2>&1)
t "the light value fails on paper, named as light" 'ERROR \[color\] line 3: #E8E8E8 on #FAF5E9 .*\(light theme\)' "$out"
n "the dark value passes" 'line 3: #000000 on #FAF5E9' "$out"
t "minified blocks on one line resolve per theme too" 'ERROR \[color\] line 5: #E8E8E8 on #FAF5E9 .*\(light theme\)' "$out"
cat > "$PROBE/darkonly.css" <<'CSS'
:root { --ink: #000000; }
[data-theme="dark"] { --ink: #F0F0F0; }
[data-theme="dark"] .card { color: var(--ink); background: #FAF5E9; }
CSS
out=$(bash "$SCRIPT" "$PROBE/darkonly.css" --brand "$BRAND" 2>&1)
t "a rule inside the dark theme is judged with dark values" 'ERROR \[color\] line 3: #F0F0F0 on #FAF5E9 .*\(dark theme\)' "$out"
n "a rule inside the dark theme is not judged with light values" 'line 3: #000000 on #FAF5E9' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
