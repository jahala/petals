#!/usr/bin/env bash
# Spec: a brand states its night shadows in an optional Night column of
# components.md's Shadow Recipes table (issues #22 and #64). export-tokens.sh
# derives that column into tokens.css's [data-theme="dark"] block and
# tokens.json's dark group, and check.sh holds a page's dark-theme
# box-shadows to it. A brand without the column, or without a dark theme,
# gets no night shadow token and no night shadow rule: nothing is guessed,
# and check.sh holds no brand's shadow colours of its own. The brand is a
# copy of the larch fixture, built here. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
EXPORT=petals/scripts/export-tokens.sh
CHECK=petals/scripts/check.sh
FX=test/fixtures/brand-template/.brand
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1: wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1: did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
is() { if [ "$2" = "$3" ]; then echo "ok - $1"; else echo "not ok - $1: wanted $3, got $2"; fails=$((fails+1)); fi }
# replace text in a file, the same on macOS and Linux (sed -i differs between them)
subst() { python3 -I -c 'import sys; p, a, b = sys.argv[1:]; s = open(p).read(); assert a in s, a; open(p, "w").write(s.replace(a, b))' "$1" "$2" "$3"; }
# the value of one token in tokens.json, by its path, or "" when absent
jval() { python3 -I -c 'import json, sys
d = json.load(open(sys.argv[1]))
for k in sys.argv[2].split("."):
    d = d.get(k, {}) if isinstance(d, dict) else {}
print(d.get("$value", "") if isinstance(d, dict) else "")' "$1" "$2" 2>/dev/null; }
dark_block() { awk '/^\[data-theme="dark"\] \{/{f=1;next} f && /^\}/{f=0} f' "$1" 2>/dev/null; }

P=$(mktemp -d); trap 'rm -rf "$P"' EXIT

# The larch brand with a Night column. shadow-float leaves its night cell
# empty: the brand states no night value for it.
cp -R "$FX" "$P/night"
subst "$P/night/components.md" '| Token | Value | Usage |
|-------|-------|-------|
| shadow-rest | `0 1px 2px rgba(31, 42, 36, 0.08)` | Resting panes |
| shadow-lift | `0 4px 16px rgba(31, 42, 36, 0.12)` | Hover lift |
| shadow-float | `0 12px 32px rgba(31, 42, 36, 0.16)` | Floating panels |' '| Token | Value | Night | Usage |
|-------|-------|-------|-------|
| shadow-rest | `0 1px 2px rgba(31, 42, 36, 0.08)` | `0 1px 2px rgba(5, 8, 6, 0.4)` | Resting panes |
| shadow-lift | `0 4px 16px rgba(31, 42, 36, 0.12)` | `0 4px 16px rgba(5, 8, 6, 0.5)` | Hover lift |
| shadow-float | `0 12px 32px rgba(31, 42, 36, 0.16)` | | Floating panels |'

# The same brand without a dark theme: colors.md's dark block removed.
cp -R "$P/night" "$P/nodark"
python3 -I - "$P/nodark/colors.md" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p, encoding="utf-8").read()
out = re.sub(r'\n\[data-theme="dark"\] \{[^}]*\}\n', "\n", s)
assert out != s
open(p, "w", encoding="utf-8").write(out)
PY

# The larch brand as the fixture writes it: no Night column.
cp -R "$FX" "$P/plain"

# A Night cell in prose rather than a CSS value.
cp -R "$P/night" "$P/prose"
subst "$P/prose/components.md" '`0 1px 2px rgba(5, 8, 6, 0.4)`' 'deeper, as on soil'

# 1. a Night column becomes dark shadow tokens in both files
out=$(bash "$EXPORT" "$P/night" 2>&1); rc=$?
is "export-tokens.sh derives the brand with a Night column" "$rc" 0
[ "$rc" -eq 0 ] || printf '%s\n' "$out" | sed 's/^/# /'
dark=$(dark_block "$P/night/tokens.css")
t "tokens.css's dark block carries the night value of shadow-rest" '^  --larch-shadow-rest: 0 1px 2px rgba\(5, 8, 6, 0\.4\);$' "$dark"
t "tokens.css's dark block carries the night value of shadow-lift" '^  --larch-shadow-lift: 0 4px 16px rgba\(5, 8, 6, 0\.5\);$' "$dark"
n "an empty Night cell gives no dark token" 'shadow-float' "$dark"
t "the dark block keeps its colours" '^  --larch-primary: #7FC29B;$' "$dark"
t ":root keeps the light recipe" '^  --larch-shadow-rest: 0 1px 2px rgba\(31, 42, 36, 0\.08\);$' "$(awk '/^:root/,/^\}/' "$P/night/tokens.css")"
is "tokens.json's dark group carries the night shadow" "$(jval "$P/night/tokens.json" dark.shadow.rest)" "0 1px 2px rgba(5, 8, 6, 0.4)"
is "tokens.json's dark group keeps its colours" "$(jval "$P/night/tokens.json" dark.color.primary)" "#7FC29B"
is "tokens.json's light shadow group keeps the light recipe" "$(jval "$P/night/tokens.json" shadow.rest)" "0 1px 2px rgba(31, 42, 36, 0.08)"
is "tokens.json gives no night value the brand left empty" "$(jval "$P/night/tokens.json" dark.shadow.float)" ""
out=$(bash "$EXPORT" "$P/night" --check 2>&1); rc=$?
is "--check passes after deriving" "$rc" 0
cp -R "$P/night" "$P/stale"
subst "$P/stale/components.md" '`0 1px 2px rgba(5, 8, 6, 0.4)`' '`0 1px 2px rgba(5, 8, 6, 0.3)`'
out=$(bash "$EXPORT" "$P/stale" --check 2>&1); rc=$?
is "--check exits 1 when a night recipe changes" "$rc" 1
t "--check names the stale dark shadow token" 'DIFF css \[dark\]--larch-shadow-rest committed: 0 1px 2px rgba\(5, 8, 6, 0\.4\) derived: 0 1px 2px rgba\(5, 8, 6, 0\.3\)' "$out"

# 2. no column, or no dark theme: no night shadow token
bash "$EXPORT" "$P/plain" >/dev/null 2>&1
n "without the column the dark block has no shadow token" 'shadow' "$(dark_block "$P/plain/tokens.css")"
is "without the column tokens.json's dark group has no shadow" "$(python3 -I -c 'import json, sys; print("shadow" in json.load(open(sys.argv[1])).get("dark", {}))' "$P/plain/tokens.json" 2>&1)" "False"
out=$(bash "$EXPORT" "$P/nodark" 2>&1); rc=$?
is "export-tokens.sh derives the brand with a Night column and no dark theme" "$rc" 0
n "without a dark theme tokens.css has no dark block" 'data-theme' "$(cat "$P/nodark/tokens.css" 2>/dev/null)"
is "without a dark theme tokens.json has no dark group" "$(python3 -I -c 'import json, sys; print("dark" in json.load(open(sys.argv[1])))' "$P/nodark/tokens.json" 2>&1)" "False"
bash "$EXPORT" "$P/prose" >/dev/null 2>&1
n "a Night cell in prose gives no dark token" 'shadow-rest' "$(dark_block "$P/prose/tokens.css")"
t "the other night values still become tokens" '^  --larch-shadow-lift: ' "$(dark_block "$P/prose/tokens.css")"

# 3. a page's dark-theme shadows are held to the night recipes
cat > "$P/page.css" <<'CSS'
.card { box-shadow: 0 1px 2px rgba(31, 42, 36, 0.08); }
[data-theme="dark"] .card { box-shadow: 0 1px 2px rgba(5, 8, 6, 0.4); }
[data-theme="dark"] .pane { box-shadow: 0 1px 2px rgba(31, 42, 36, 0.08); }
[data-theme="dark"] .float { box-shadow: 0 12px 32px rgba(31, 42, 36, 0.16); }
[data-theme="dark"] {
  .a { color: #ECE8DC; }
  .b { box-shadow: 0 4px 16px rgba(31, 42, 36, 0.12); }
}
@media (prefers-color-scheme: dark) {
  .c { box-shadow: 0 4px 16px rgba(5, 8, 6, 0.5); }
  .d { box-shadow: 0 4px 16px rgba(31, 42, 36, 0.12); }
}
.e { box-shadow: 0 4px 16px rgba(31, 42, 36, 0.12); }
CSS
out=$(bash "$CHECK" "$P/page.css" --brand "$P/night" 2>&1)
t "check.sh judges the page by the brand with a Night column" '^Result: ' "$out"
n "the light recipe on the light theme passes" 'line 1:' "$out"
n "the night recipe in the dark block passes" 'line 2:' "$out"
t "the light recipe in the dark block is flagged, with its night value" 'WARNING \[surface\] line 3: box-shadow in the dark theme is shadow-rest.s light recipe\. Its night recipe is 0 1px 2px rgba\(5, 8, 6, 0\.4\)' "$out"
n "a recipe with no night value passes in the dark block" 'line 4:' "$out"
t "the second rule nested in a dark block is held to the night recipe" 'WARNING \[surface\] line 7: box-shadow in the dark theme is shadow-lift.s light recipe' "$out"
n "the night recipe under prefers-color-scheme: dark passes" 'line 10:' "$out"
t "the light recipe under prefers-color-scheme: dark is flagged" 'WARNING \[surface\] line 11: box-shadow in the dark theme is shadow-lift.s light recipe' "$out"
n "the light recipe after the dark blocks close passes" 'line 13:' "$out"
n "the night tint in a shadow is on-brand" 'ERROR \[color\]' "$out"
n "the night messages carry no em dash" '—' "$out"
sarif=$(bash "$CHECK" "$P/page.css" --brand "$P/night" --format sarif 2>&1)
t "SARIF files the night finding under surface/shadow" '"ruleId":"surface/shadow","level":"warning","message":\{"text":"box-shadow in the dark theme' "$sarif"

out=$(bash "$CHECK" "$P/page.css" --brand "$P/plain" 2>&1)
t "check.sh judges the page by the brand without the column" '^Result: ' "$out"
n "without the column no night rule fires" 'in the dark theme' "$out"
n "without the column the light recipe in the dark block passes" 'line 3:' "$out"
t "without the column a night shadow is a recipe the brand never stated" 'WARNING \[surface\] line 2: box-shadow matches no shadow recipe' "$out"
out=$(bash "$CHECK" "$P/page.css" --brand "$P/nodark" 2>&1)
t "check.sh judges the page by the brand without a dark theme" '^Result: ' "$out"
n "without a dark theme no night rule fires" 'in the dark theme' "$out"
t "without a dark theme a night shadow is a recipe the brand never stated" 'WARNING \[surface\] line 2: box-shadow matches no shadow recipe' "$out"
out=$(bash "$CHECK" "$P/page.css" --brand "$P/prose" 2>&1)
t "check.sh judges the page by the brand with a prose Night cell" '^Result: ' "$out"
n "a Night cell in prose sets no night rule, as it sets no token" 'line 3:' "$out"
t "the other night values still hold" 'WARNING \[surface\] line 7: box-shadow in the dark theme is shadow-lift.s light recipe' "$out"

# 4. check.sh holds no brand's shadow colours: plotplot's ink and night
#    tint, which it once swapped one for the other (#64)
hits=$(grep -nE '58,[ ]*39,[ ]*24|[^0-9.]8,[ ]*6,[ ]*4[^0-9]' "$CHECK")
is "check.sh holds no brand's shadow colours" "$hits" ""

echo; echo "$fails failure(s)"; exit "$fails"
