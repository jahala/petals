#!/usr/bin/env bash
# Spec: a fetch never overwrites a brand file the project commits. A tracked
# file under the target is canonical in that repository (petals' own product
# layer is), so the fetch keeps it byte for byte and names it on stderr.
# Untracked files are the fetched cache and are replaced as before. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
SCRIPT="$PWD/petals/scripts/fetch-brand.sh"
SRC="$PWD/test/fixtures/brand-repo-test-v1.1.0"
fails=0
ok() { if [ "$2" = 0 ]; then echo "ok - $1"; else echo "not ok - $1"; fails=$((fails+1)); fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
R="$P/proj"; mkdir -p "$R/.brand"
git -C "$R" init -q -b main
printf 'OURS\n' > "$R/.brand/colors.md"
git -C "$R" add .brand/colors.md && git -C "$R" -c user.name=t -c user.email=t@t commit -qm ours
printf 'OLD CACHE\n' > "$R/.brand/typography.md"
err=$(bash "$SCRIPT" "file://$SRC" --target "$R/.brand" 2>&1 >/dev/null); rc=$?
ok "the fetch succeeds (rc $rc)" "$rc"
if [ "$(cat "$R/.brand/colors.md")" = "OURS" ]; then ok "a committed brand file survives the fetch" 0; else ok "a committed brand file survives the fetch" 1; fi
if echo "$err" | grep -q 'colors.md'; then ok "the kept file is named on stderr" 0; else ok "the kept file is named on stderr" 1; fi
if cmp -s "$SRC/.brand/typography.md" "$R/.brand/typography.md"; then ok "an untracked cached file is replaced" 0; else ok "an untracked cached file is replaced" 1; fi
if cmp -s "$SRC/.brand/voice.md" "$R/.brand/voice.md"; then ok "files the project lacks are fetched" 0; else ok "files the project lacks are fetched" 1; fi
if [ -z "$(git -C "$R" status --porcelain -- .brand/colors.md)" ]; then ok "git sees no change to the committed file" 0; else ok "git sees no change to the committed file" 1; fi
[ "$fails" = 0 ]
