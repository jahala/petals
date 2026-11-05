#!/usr/bin/env bash
# Spec: `petals guard <hook>` is petals' commit-time face, which the stem's
# planted git hooks call. pre-commit judges the index (what will be
# committed, not the working tree); commit-msg judges the index again with
# the message file's Petals-allow trailers. Exit 0 lets the commit through,
# nonzero refuses it with the reason on stderr (issue #4). Prints TAP.
cd "$(dirname "$0")/.." || exit 1
PETALS="$PWD/petals/bin/petals"
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
R="$P/repo"; mkdir -p "$R"
g() { git -C "$R" -c user.name=t -c user.email=t@t "$@"; }
g init -q -b main
cp -R test/fixtures/brand-plotplot-v1.9.0/.brand "$R/.brand"
printf 'brand:\n  version: v1.9.0\n' > "$R/.petalsrc"
g add -A && g commit -qm base
# staged: an off-palette page; working tree: the same page fixed but not staged
printf '<p style="color:#3B82F6">x</p>\n' > "$R/page.html"; g add page.html
printf '<p style="color:#357E2C">x</p>\n' > "$R/page.html"
err=$(cd "$R" && "$PETALS" guard pre-commit 2>&1 >/dev/null); rc=$?
[ "$rc" -ne 0 ] && echo "ok - pre-commit refuses an index with an error" || { echo "not ok - pre-commit refuses an index with an error"; fails=$((fails+1)); }
t "pre-commit judges what is staged, not the working tree" '#3B82F6' "$err"
t "the refusal names the file and line" 'page\.html.*line 1' "$err"
t "the refusal says it blocks the commit, not that something crashed" 'block this commit' "$err"
printf 'add the page\n\nPetals-allow: color/off-palette approved for launch\n' > "$P/msg"
(cd "$R" && "$PETALS" guard commit-msg "$P/msg") >/dev/null 2>"$P/err"; rc=$?
[ "$rc" -eq 0 ] && echo "ok - commit-msg lets an allowed finding through" || { echo "not ok - commit-msg lets an allowed finding through: $(cat "$P/err")"; fails=$((fails+1)); }
printf 'add the page\n' > "$P/msg2"
(cd "$R" && "$PETALS" guard commit-msg "$P/msg2") >/dev/null 2>&1; rc=$?
[ "$rc" -ne 0 ] && echo "ok - commit-msg without an allowance refuses" || { echo "not ok - commit-msg without an allowance refuses"; fails=$((fails+1)); }
g add page.html
(cd "$R" && "$PETALS" guard pre-commit) >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && echo "ok - a clean index passes" || { echo "not ok - a clean index passes"; fails=$((fails+1)); }
(cd "$R" && "$PETALS" guard pre-push) >/dev/null 2>&1; rc=$?
[ "$rc" -eq 0 ] && echo "ok - a hook petals does not judge passes through" || { echo "not ok - a hook petals does not judge passes through (rc $rc)"; fails=$((fails+1)); }
# the entry point itself: no arguments is usage on stderr and exit 2, with no
# line of its header running as a command
out=$("$PETALS" 2>&1 >/dev/null); rc=$?
[ "$rc" -eq 2 ] && echo "ok - no arguments exits 2" || { echo "not ok - no arguments exits 2 (rc $rc)"; fails=$((fails+1)); }
t "no arguments prints the usage" '^usage: petals guard' "$out"
if echo "$out" | grep -qE 'command not found|No such file'; then echo "not ok - nothing in the entry point runs by accident"; fails=$((fails+1)); else echo "ok - nothing in the entry point runs by accident"; fi
echo; echo "$fails failure(s)"; exit "$fails"
