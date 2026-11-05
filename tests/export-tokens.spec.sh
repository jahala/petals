#!/usr/bin/env bash
# Spec for petals/scripts/export-tokens.sh
# Run from the repo root: bash tests/export-tokens.spec.sh
cd "$(dirname "$0")/.." || exit 1
SCRIPT=petals/scripts/export-tokens.sh
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }

[ -f "$SCRIPT" ] || { echo "not ok - export-tokens.sh does not exist"; exit 1; }

# Runs against a scratch copy of the frozen fixture brand, so the spec never
# writes into the repository; the scratch folder is removed on exit.
SCRATCH=$(mktemp -d); trap 'rm -rf "$SCRATCH"' EXIT
cp -R test/fixtures/brand-plotplot-v2.0.0/.brand "$SCRATCH/.brand"
BRAND="$SCRATCH/.brand"

# Test a: Script runs successfully
OUT=$(bash "$SCRIPT" "$BRAND" 2>&1); RC=$?
t "script exits 0" '0' "$RC"

# Test b: tokens.css contains expected CSS variables
CSS=$(cat "$BRAND/tokens.css")
t "tokens.css has --pp-primary" '--pp-primary:' "$CSS"
t "tokens.css has --pp-accent" '--pp-accent:' "$CSS"

# Test c: tokens.json is valid JSON
if python3 -c "import json; json.load(open('$BRAND/tokens.json'))" 2>/dev/null; then
  echo "ok - tokens.json is valid JSON"
else
  echo "not ok - tokens.json is valid JSON"; fails=$((fails+1))
fi

# Test d: CSS comment header contains brand name (from identity.md Brand Name field)
BRAND_NAME=$(awk -F'|' '/Brand Name/ {gsub(/^[[:space:]]+|[[:space:]]+$/,"",$3); print $3; exit}' "$BRAND/identity.md")
t "CSS header has brand name \"$BRAND_NAME\"" "$BRAND_NAME" "$(head -3 "$BRAND/tokens.css")"

# Test e: No hex values in tokens.css outside the colors.md palette
PALETTE_HEXES=$(grep -ohE '#[0-9A-Fa-f]{6}' "$BRAND/colors.md" | tr 'a-f' 'A-F' | sort -u)
EXTRA=$(grep -ohE '#[0-9A-Fa-f]{6}' "$BRAND/tokens.css" | tr 'a-f' 'A-F' | sort -u | while read h; do echo "$PALETTE_HEXES" | grep -qF "$h" || echo "$h"; done)
t "no hex in tokens.css outside palette" '' "$EXTRA"

# Test f: Missing brand directory → exit non-zero with error message
OUT_MISSING=$(bash "$SCRIPT" /nonexistent/brand/dir/99999 2>&1); RC_MISSING=$?
t "missing brand dir exit non-zero" '[1-9]' "$RC_MISSING"
t "missing brand dir shows error" 'Missing' "$OUT_MISSING"

echo; echo "$fails failure(s)"; exit "$fails"
