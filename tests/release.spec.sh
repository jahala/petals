#!/usr/bin/env bash
# Spec: scripts/build-release.sh builds the release artifact the stem plants:
# a .tar.gz whose only member is an executable `petals` that carries every
# file it needs, so a copy of that one file runs alone (the stem copies just
# <artifact root>/petals into .plotplot/bin/). The build is deterministic and
# writes a sha256 beside the tarball (issue #4, part D). Prints TAP.
cd "$(dirname "$0")/.." || exit 1
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
bash scripts/build-release.sh "$P/dist1" >/dev/null 2>&1 || { echo "not ok - the build runs"; exit 1; }
bash scripts/build-release.sh "$P/dist2" >/dev/null 2>&1
v=$(petals/bin/petals --version | awk '{print $2}')
tgz="$P/dist1/petals-$v.tar.gz"
[ -f "$tgz" ] && echo "ok - the artifact is named for the version" || { echo "not ok - the artifact is named for the version ($(ls "$P/dist1"))"; fails=$((fails+1)); }
t "the tarball holds only the petals executable" '^petals$' "$(tar -tzf "$tgz" 2>&1)"
want=$(cut -d' ' -f1 "$tgz.sha256" 2>/dev/null); got=$(shasum -a 256 "$tgz" | cut -d' ' -f1)
[ -n "$want" ] && [ "$want" = "$got" ] && echo "ok - the sha256 file matches the tarball" || { echo "not ok - the sha256 file matches the tarball"; fails=$((fails+1)); }
cmp -s "$tgz" "$P/dist2/petals-$v.tar.gz" && echo "ok - two builds of one commit are byte-identical" || { echo "not ok - two builds of one commit are byte-identical"; fails=$((fails+1)); }
# the stem's view: one file, alone, in an empty bin folder, with its own cache
mkdir -p "$P/planted/.plotplot/bin" "$P/cache"
tar -xzf "$tgz" -C "$P/planted/.plotplot/bin"
B="$P/planted/.plotplot/bin/petals"
[ -x "$B" ] && echo "ok - the planted file is executable" || { echo "not ok - the planted file is executable"; fails=$((fails+1)); }
t "the planted file runs alone" "^petals $v\$" "$(XDG_CACHE_HOME="$P/cache" "$B" --version 2>&1)"
R="$P/repo"; mkdir -p "$R"; g() { git -C "$R" -c user.name=t -c user.email=t@t "$@"; }
g init -q -b main; cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$R/.brand"; printf 'brand:\n  version: v1.9.0\n' > "$R/.petalsrc"
g add -A && g commit -qm base; printf '<p style="color:#3B82F6">x</p>\n' > "$R/page.html"
out=$(cd "$R" && XDG_CACHE_HOME="$P/cache" "$B" gate --format sarif 2>&1)
t "the planted file judges a change" '"ruleId":"color/off-palette"' "$out"
# in a planted repository the copy lives under its .plotplot/, inside the stem's footprint
found=$(find "$P/planted/.plotplot/cache/petals" -path '*/petals/bin/petals' -perm -u+x 2>/dev/null | head -1)
[ -n "$found" ] && echo "ok - a planted petals unpacks under the repository's .plotplot/cache/" || { echo "not ok - a planted petals unpacks under the repository's .plotplot/cache/"; fails=$((fails+1)); }
[ ! -d "$P/cache/petals" ] && echo "ok - a planted petals leaves the user cache alone" || { echo "not ok - a planted petals leaves the user cache alone"; fails=$((fails+1)); }
# outside a planted repository it uses the user cache
mkdir -p "$P/loose"; cp "$B" "$P/loose/petals"
XDG_CACHE_HOME="$P/cache" "$P/loose/petals" --version >/dev/null 2>&1
[ -d "$P/cache/petals" ] && echo "ok - a loose petals unpacks into the user cache" || { echo "not ok - a loose petals unpacks into the user cache"; fails=$((fails+1)); }
# a new version's first run removes older copies with trash, never rm
mkdir -p "$P/fakebin" "$P/cache2/petals/0ld0ld0ld0ld0ld0/petals"
printf '#!/bin/sh\nfor a in "$@"; do echo "$a" >> "%s/trashed"; mv "$a" "%s/.trashed-$(basename "$a")"; done\n' "$P" "$P" > "$P/fakebin/trash"; chmod +x "$P/fakebin/trash"
PATH="$P/fakebin:$PATH" XDG_CACHE_HOME="$P/cache2" "$P/loose/petals" --version >/dev/null 2>&1
t "an older copy is handed to trash" '0ld0ld0ld0ld0ld0' "$(cat "$P/trashed" 2>/dev/null)"
n=$(find "$P/cache2/petals" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
[ "$n" = 1 ] && echo "ok - only the current copy remains" || { echo "not ok - only the current copy remains ($n)"; fails=$((fails+1)); }
# without trash, the older copy is named, never deleted
mkdir -p "$P/nobin" "$P/cache3/petals/0ld0ld0ld0ld0ld0/petals"
for tool in bash sh sed tail base64 tar gzip mktemp mv dirname basename cat mkdir find wc tr pwd env git python3 awk grep sort head cut uname rm cp ls printf; do p=$(command -v "$tool" 2>/dev/null) && ln -sf "$p" "$P/nobin/$tool"; done
err=$(PATH="$P/nobin" XDG_CACHE_HOME="$P/cache3" "$P/loose/petals" --version 2>&1 >/dev/null)
[ -d "$P/cache3/petals/0ld0ld0ld0ld0ld0" ] && echo "ok - without trash the older copy stays" || { echo "not ok - without trash the older copy stays"; fails=$((fails+1)); }
t "without trash the older copy is named on stderr" '0ld0ld0ld0ld0ld0.*older' "$err"
echo; echo "$fails failure(s)"; exit "$fails"
