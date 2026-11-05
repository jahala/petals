#!/usr/bin/env bash
# Spec: `petals review <page> [--note <text>]...` writes an index page in the
# brand, serves the project on a free local port from a detached server,
# opens it (not here: --no-open), and prints the stop command; re-running adds
# to the same index; `petals review --stop` ends the server and hands the
# review folder to trash, leaving nothing behind. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
PETALS="$PWD/petals/bin/petals"
SCRIPT=petals/scripts/check.sh
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
P=$(mktemp -d)
R="$P/proj"; mkdir -p "$R/drafts" "$P/fakebin"
printf '#!/bin/sh\nfor a in "$@"; do mv "$a" "%s/.t-$(basename "$a")"; done\n' "$P" > "$P/fakebin/trash"; chmod +x "$P/fakebin/trash"
export PATH="$P/fakebin:$PATH"
cleanup() { (cd "$R" && "$PETALS" review --stop >/dev/null 2>&1); rm -rf "$P"; }
trap cleanup EXIT
git -C "$R" init -q -b main
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$R/.brand"
printf 'brand:\n  version: v1.9.0\n' > "$R/.petalsrc"
printf '<!doctype html><title>bed</title><h1>The bed page</h1>\n' > "$R/drafts/bed.html"
printf '<!doctype html><title>two</title><h1>Second</h1>\n' > "$R/drafts/two.html"
out=$(cd "$R" && "$PETALS" review drafts/bed.html --note "the new heading face" --no-open 2>&1); rc=$?
[ "$rc" -eq 0 ] && echo "ok - review starts" || { echo "not ok - review starts: $out"; fails=$((fails+1)); }
url=$(echo "$out" | grep -oE 'http://127\.0\.0\.1:[0-9]+/[^ ]*' | head -1)
t "it prints the index URL on 127.0.0.1" '^http://127\.0\.0\.1:[0-9]+/' "$url"
t "it prints the stop command" 'petals review --stop' "$out"
index=$(curl -fsS "$url" 2>/dev/null)
t "the index links the page" 'href="[^"]*drafts/bed\.html"' "$index"
t "the index says what to look for" 'the new heading face' "$index"
page=$(curl -fsS "${url%/.petals-review/*}/drafts/bed.html" 2>/dev/null)
t "the page itself is served" 'The bed page' "$page"
grep -qx '.petals-review/' "$R/.git/info/exclude" && echo "ok - the review folder stays out of commits" || { echo "not ok - the review folder stays out of commits"; fails=$((fails+1)); }
(cd "$R" && "$PETALS" review drafts/two.html --no-open >/dev/null 2>&1)
index=$(curl -fsS "$url" 2>/dev/null)
t "re-running adds to the same index on the same server" 'drafts/two\.html' "$index"
t "re-running keeps the first page" 'drafts/bed\.html' "$index"
out=$(bash "$SCRIPT" "$R/.petals-review/index.html" --brand "$R/.brand" 2>&1)
t "the index page passes petals check against the brand" '^Result: PASS' "$out"
(cd "$R" && "$PETALS" review --stop >/dev/null 2>&1)
curl -fsS "$url" >/dev/null 2>&1 && { echo "not ok - --stop ends the server"; fails=$((fails+1)); } || echo "ok - --stop ends the server"
[ ! -e "$R/.petals-review" ] && echo "ok - --stop leaves no review folder behind" || { echo "not ok - --stop leaves no review folder behind"; fails=$((fails+1)); }
# in a git worktree .git is a file; a first review there must still keep its folder out of commits
R2="$P/proj2"; mkdir -p "$R2"; cp -R "$R/.brand" "$R/.petalsrc" "$R/drafts" "$R2/"
git -C "$R2" init -q -b main && git -C "$R2" add -A && git -C "$R2" -c user.name=t -c user.email=t@t commit -qm base
git -C "$R2" worktree add -q "$P/wt" -b wt
[ -f "$P/wt/.git" ] && echo "ok - the worktree probe is a worktree" || { echo "not ok - the worktree probe is a worktree"; fails=$((fails+1)); }
(cd "$P/wt" && "$PETALS" review drafts/bed.html --no-open >/dev/null 2>&1)
wtstatus=$(git -C "$P/wt" status --porcelain 2>&1)
(cd "$P/wt" && "$PETALS" review --stop >/dev/null 2>&1)
case "$wtstatus" in *petals-review*) echo "not ok - in a worktree the review folder stays out of commits"; echo "# $wtstatus"; fails=$((fails+1)) ;; *) echo "ok - in a worktree the review folder stays out of commits" ;; esac
echo; echo "$fails failure(s)"; exit "$fails"
