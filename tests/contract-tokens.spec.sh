#!/usr/bin/env bash
# Spec: a component contract cites only tokens the brand defines. A contract
# naming a token tokens.css does not have would send an agent to build with a
# value nobody chose, so export-tokens.sh --check fails on it, naming the file
# and the token. The blank forms petals ships cite only real tokens. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
EXPORT=petals/scripts/export-tokens.sh
fails=0
ok() { if [ "$2" = 0 ]; then echo "ok - $1"; else echo "not ok - $1"; fails=$((fails+1)); fi }
has() { if printf '%s\n' "$3" | grep -qE -e "$2"; then ok "$1" 0; else ok "$1" 1; echo "# wanted /$2/"; fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
cp -R test/fixtures/brand-plotplot-v1.11.0/.brand "$P/b"
bash "$EXPORT" "$P/b" >/dev/null 2>&1 || { echo "not ok - the fixture brand derives its tokens"; exit 1; }
mkdir -p "$P/b/components/families"
printf '# Button: contract\n\n| Use | Token |\n|-----|-------|\n| fill | --pp-primary |\n| radius | --pp-radius-md |\n' > "$P/b/components/button.md"
bash "$EXPORT" "$P/b" --check >/dev/null 2>&1; rc=$?
ok "a contract citing only real tokens passes --check (rc $rc)" "$rc"
printf '# Toggle: contract\n\n| Use | Token |\n|-----|-------|\n| ring | --pp-focus-ring |\n' > "$P/b/components/families/toggles.md"
out=$(bash "$EXPORT" "$P/b" --check 2>&1); rc=$?
if [ "$rc" = 1 ]; then ok "a contract citing an unknown token fails --check" 0; else ok "a contract citing an unknown token fails --check (rc $rc)" 1; fi
has "the unknown token is named with its contract" 'UNKNOWN components/families/toggles\.md --pp-focus-ring' "$out"
printf '# Note\n\nRun export-tokens.sh --check after editing; --format sarif also works.\n' > "$P/b/components/families/toggles.md"
bash "$EXPORT" "$P/b" --check >/dev/null 2>&1; rc=$?
ok "a command-line flag in a contract's prose is not read as a token (rc $rc)" "$rc"
rm -rf "$P/b/components"; mkdir -p "$P/b/components"
cp petals/templates/components/component.md petals/templates/components/family.md "$P/b/components/"
out=$(bash "$EXPORT" "$P/b" --check 2>&1); rc=$?
ok "the blank contract forms cite only real tokens (rc $rc)" "$rc"
[ "$rc" = 0 ] || printf '%s\n' "$out" | sed 's/^/# /'
[ "$fails" = 0 ]
