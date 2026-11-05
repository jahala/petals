#!/usr/bin/env bash
# Spec: export-tokens.sh derives tokens.css and tokens.json from the brand's
# markdown, and --check exits 1 listing each token where the committed files
# and the markdown disagree. Known case: plotplot v1.9.0, whose
# committed tokens were hand-edited; every difference --check reports there
# must be one recorded, with its reason, in
# test/fixtures/tokens/v1.9.0-known-differences.txt. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
EXPORT=petals/scripts/export-tokens.sh
KNOWN=test/fixtures/tokens/v1.9.0-known-differences.txt
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$P/v19"

# 1. the known case: every difference is a recorded hand edit, and none is missed
out=$(bash "$EXPORT" "$P/v19" --check 2>&1); rc=$?
[ "$rc" -eq 1 ] && echo "ok - v1.9.0: --check exits 1 on hand-edited tokens" || { echo "not ok - v1.9.0: --check exits 1 on hand-edited tokens (rc $rc)"; fails=$((fails+1)); }
reported=$(printf '%s\n' "$out" | grep -oE '^DIFF [a-z]+ [^ ]+' | sort -u)
recorded=$(grep -oE '^DIFF [a-z]+ [^ ]+' "$KNOWN" 2>/dev/null | sort -u)
[ -n "$reported" ] && [ "$reported" = "$recorded" ] && echo "ok - v1.9.0: every reported difference is recorded with a reason, and every recorded one is reported" || { echo "not ok - v1.9.0: reported and recorded differences match"; diff <(echo "$recorded") <(echo "$reported") | sed 's/^/# /'; fails=$((fails+1)); }
n "v1.9.0: no difference without a reason in the record" '^DIFF [^#]*$' "$(cat "$KNOWN" 2>/dev/null)"
cmp -s test/fixtures/brand-plotplot-v1.9.0/.brand/tokens.css "$P/v19/tokens.css" && echo "ok - --check writes nothing" || { echo "not ok - --check writes nothing"; fails=$((fails+1)); }

# 2. derive, then check: a fresh derivation matches itself
bash "$EXPORT" "$P/v19" >/dev/null 2>&1
out=$(bash "$EXPORT" "$P/v19" --check 2>&1); rc=$?
[ "$rc" -eq 0 ] && echo "ok - freshly derived tokens pass --check" || { echo "not ok - freshly derived tokens pass --check: $out"; fails=$((fails+1)); }

# 3. the derivation reads the brand's own declarations
css=$(cat "$P/v19/tokens.css")
t "colour tokens come from colors.md's CSS blocks" '--pp-petals: #CC6A37;' "$css"
t "dark overrides come from colors.md's dark block" '--pp-umbel: #5F6A18;' "$(awk '/data-theme="dark"/,/}/' "$P/v19/tokens.css")"
t "the terminal colours keep the brand's names" '--pp-term-bg: #1C1610;' "$css"
t "a stroke token carries its width only" '--pp-stroke-hairline: 1px;' "$css"
t "a shadow token is the recipe without backticks" '--pp-shadow-lift: 0 2px 4px rgba\(58, 39, 24, 0\.05\)' "$css"
n "no table header becomes a token" '--pp-(space-)?[Tt]oken' "$css"
n "no row label becomes a colour token" '--pp-(find|shape|build|ship):' "$css"
n "no prose value becomes a token" '→|over 0\.' "$css"
n "the generated files carry no em dash" '—' "$css$(cat "$P/v19/tokens.json")"
# 4. one model feeds both files: every CSS token has its JSON twin with the same value
python3 -I - "$P/v19/tokens.css" "$P/v19/tokens.json" <<'PY' | sed 's/^/# /'
import json, re, sys
css = re.sub(r'/\*.*?\*/', '', open(sys.argv[1]).read(), flags=re.S)
root = dict(re.findall(r'(--pp-[\w-]+)\s*:\s*([^;]+);', css.split('[data-theme')[0]))
vals = set()
def walk(x):
    if isinstance(x, dict):
        if '$value' in x: vals.add(json.dumps(x['$value']) if not isinstance(x['$value'], str) else x['$value'])
        else: [walk(v) for k, v in x.items() if not k.startswith('$')]
walk(json.load(open(sys.argv[2])))
missing = [k for k, v in root.items() if ' '.join(v.split()) not in vals]
print("missing-in-json:", len(missing), missing[:5])
sys.exit(1 if missing else 0)
PY
[ "${PIPESTATUS[0]}" -eq 0 ] && echo "ok - every :root token has its value in tokens.json" || { echo "not ok - every :root token has its value in tokens.json"; fails=$((fails+1)); }

# 5. a markdown change the tokens did not follow is caught by name
sed -i '' 's/--pp-petals: #CC6A37;/--pp-petals: #CC6A38;/' "$P/v19/colors.md"
sed -i '' 's/| petals | #CC6A37 |/| petals | #CC6A38 |/' "$P/v19/colors.md"
out=$(bash "$EXPORT" "$P/v19" --check 2>&1); rc=$?
[ "$rc" -eq 1 ] && echo "ok - a stale token fails --check" || { echo "not ok - a stale token fails --check (rc $rc)"; fails=$((fails+1)); }
t "the stale token is named with both values" 'DIFF css --pp-petals .*#CC6A37.*#CC6A38' "$out"
# 6. breakpoints take their names from a Token column when the table has one
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$P/named"
python3 -I - "$P/named/layout.md" <<'PY'
import sys
p = sys.argv[1]; s = open(p, encoding="utf-8").read()
s = s.replace("| Breakpoint | What changes |\n|------------|--------------|\n| 880px |", "| Breakpoint | Token | What changes |\n|------------|-------|--------------|\n| 880px | breakpoint-stack |")
s = s.replace("| 520px | Dense", "| 520px | breakpoint-dense | Dense")
open(p, "w", encoding="utf-8").write(s)
PY
bash "$EXPORT" "$P/named" >/dev/null 2>&1
t "a Token column names the breakpoint" '--pp-breakpoint-stack: 880px;' "$(cat "$P/named/tokens.css")"
t "a Token column names the second breakpoint" '--pp-breakpoint-dense: 520px;' "$(cat "$P/named/tokens.css")"
echo; echo "$fails failure(s)"; exit "$fails"
