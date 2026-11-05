#!/usr/bin/env bash
# Spec: a `Petals-allow: <rule> <reason>` trailer lets a finding through on
# the record: it stays in the log as a note carrying the reason as a SARIF
# suppression. --strict reports it at its own level again. A trailer without
# a reason allows nothing (issue #4, part B). Prints TAP.
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
printf '<p style="color:#3B82F6">launch blue</p>\n' > "$R/page.html"
rows() { python3 -I -c 'import json,sys
for r in json.load(sys.stdin)["runs"][0]["results"]:
    s = r.get("suppressions") or []
    print(r["ruleId"], r["level"], (s[0].get("kind","") + ":" + s[0].get("justification","")) if s else "-")'; }
g add -A && g commit -qm "launch page" -m "Petals-allow: color/off-palette the launch blue is approved for this campaign only"
out=$(cd "$R" && "$PETALS" gate --base main~1 --format sarif 2>/dev/null | rows)
t "an allowed finding becomes a note" '^color/off-palette note ' "$out"
t "it carries the reason as a SARIF suppression" 'external:the launch blue is approved for this campaign only' "$out"
out=$(cd "$R" && "$PETALS" gate --base main~1 --format sarif --strict 2>/dev/null | rows)
t "--strict reports it at its own level, suppression kept" '^color/off-palette error external:the launch blue' "$out"
g commit -q --amend -m "launch page" -m "Petals-allow: color/off-palette"
out=$(cd "$R" && "$PETALS" gate --base main~1 --format sarif 2>"$P/err" | rows)
t "a trailer without a reason allows nothing" '^color/off-palette error -' "$out"
t "and says so" 'no reason' "$(cat "$P/err")"
g commit -q --amend -m "launch page" -m "Petals-allow: voice/forbidden-term not this rule"
out=$(cd "$R" && "$PETALS" gate --base main~1 --format sarif 2>/dev/null | rows)
t "a trailer for another rule allows nothing here" '^color/off-palette error -' "$out"
# commit time: the message file the commit-msg hook hands over
g checkout -q -b commit-time main~1
printf '<p style="color:#3B82F6">launch blue</p>\n' > "$R/page.html"
printf 'launch page\n\nPetals-allow: color/off-palette approved for the launch\n' > "$P/msg"
out=$(cd "$R" && "$PETALS" gate --message-file "$P/msg" --format sarif 2>/dev/null | rows)
t "--message-file allows at commit time" '^color/off-palette note external:approved for the launch' "$out"
echo; echo "$fails failure(s)"; exit "$fails"
