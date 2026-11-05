#!/usr/bin/env bash
# Spec: vendor.sh copies petals/ into another repository with a VERSION stamp
# (the petals commit, its tag when there is one, and a checksum per file), and
# --check fails when the copy is not exactly the version it names.
# Prints TAP. Run from the repo root.
cd "$(dirname "$0")/.." || exit 1
VENDOR="$PWD/petals/scripts/vendor.sh"
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
# a clean petals checkout at this commit, with this working tree's petals/ in it
git clone -q --no-hardlinks . "$P/src" 2>/dev/null
rsync -a --delete petals/ "$P/src/petals/"
git -C "$P/src" add -A petals && git -C "$P/src" -c user.name=t -c user.email=t@t commit -qm "petals under test" --allow-empty
want=$(git -C "$P/src" rev-parse HEAD)
mkdir -p "$P/umbrella"
out=$(bash "$VENDOR" --from "$P/src" "$P/umbrella" 2>&1); rc=$?
[ "$rc" -eq 0 ] && echo "ok - vendoring a clean checkout succeeds" || { echo "not ok - vendoring a clean checkout succeeds: $out"; fails=$((fails+1)); }
t "the stamp names the petals commit" "^petals [^ ]+ $want\$" "$(head -1 "$P/umbrella/petals/VERSION" 2>/dev/null)"
t "the copy holds the skill" 'SKILL.md' "$(ls "$P/umbrella/petals" 2>/dev/null)"
out=$(bash "$VENDOR" --check "$P/umbrella" 2>&1); rc=$?
[ "$rc" -eq 0 ] && echo "ok - an untouched copy passes --check" || { echo "not ok - an untouched copy passes --check: $out"; fails=$((fails+1)); }
t "--check names the version it verified" "matches petals .*${want:0:12}" "$out"
echo "# local edit" >> "$P/umbrella/petals/scripts/check.sh"
out=$(bash "$VENDOR" --check "$P/umbrella" 2>&1); rc=$?
[ "$rc" -eq 1 ] && echo "ok - an edited file fails --check" || { echo "not ok - an edited file fails --check (rc $rc)"; fails=$((fails+1)); }
t "the edited file is named" 'changed: scripts/check.sh' "$out"
bash "$VENDOR" --from "$P/src" "$P/umbrella" >/dev/null 2>&1
echo extra > "$P/umbrella/petals/extra.md"; rm "$P/umbrella/petals/references/voice-guide.md"
out=$(bash "$VENDOR" --check "$P/umbrella" 2>&1)
t "an extra file is named" 'extra: extra.md' "$out"
t "a missing file is named" 'missing: references/voice-guide.md' "$out"
mkdir -p "$P/fakebin"; printf '#!/bin/sh\nfor a in "$@"; do echo "$a" >> "%s/trashed"; mv "$a" "%s/.t-$(basename "$a")"; done\n' "$P" "$P" > "$P/fakebin/trash"; chmod +x "$P/fakebin/trash"
PATH="$P/fakebin:$PATH" bash "$VENDOR" --from "$P/src" "$P/umbrella" >/dev/null 2>&1
t "a file petals no longer ships goes to trash, never rm" 'extra\.md' "$(cat "$P/trashed" 2>/dev/null)"
[ ! -e "$P/umbrella/petals/extra.md" ] && [ -e "$P/umbrella/petals/references/voice-guide.md" ] && echo "ok - vendoring again restores the exact copy" || { echo "not ok - vendoring again restores the exact copy"; fails=$((fails+1)); }
echo dirty >> "$P/src/petals/SKILL.md"
out=$(bash "$VENDOR" --from "$P/src" "$P/umbrella" 2>&1); rc=$?
[ "$rc" -eq 2 ] && echo "ok - a dirty source is refused" || { echo "not ok - a dirty source is refused (rc $rc)"; fails=$((fails+1)); }
t "the refusal says why" 'uncommitted changes' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
