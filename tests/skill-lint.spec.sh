#!/usr/bin/env bash
# Spec: lint-skills.sh fails a skill the harness would drop without a word:
# no description, a name that differs from its directory, or a skill no
# always-on instruction (AGENTS.md, CLAUDE.md) names. Prints TAP.
cd "$(dirname "$0")/.." || exit 1
LINT=petals/scripts/lint-skills.sh
fails=0
t() { if echo "$3" | grep -qE -e "$2"; then echo "ok - $1"; else echo "not ok - $1 — wanted /$2/"; fails=$((fails+1)); fi }
n() { if echo "$3" | grep -qE -e "$2"; then echo "not ok - $1 — did not want /$2/"; fails=$((fails+1)); else echo "ok - $1"; fi }
P=$(mktemp -d); trap 'rm -rf "$P"' EXIT
mk() { mkdir -p "$P/.claude/skills/$1"; printf '%s' "$2" > "$P/.claude/skills/$1/SKILL.md"; }
mk good $'---\nname: good\ndescription: >-\n  A skill that does one thing.\n---\n# good\n'
mk nodesc $'---\nname: nodesc\n---\n# nodesc\n'
mk renamed $'---\nname: other-name\ndescription: Says what it does.\n---\n'
mk unnamed $'---\nname: unnamed\ndescription: Nobody mentions me.\n---\n'
printf 'Skills: good, nodesc, renamed (other-name).\n' > "$P/AGENTS.md"
out=$(bash "$LINT" "$P" 2>&1); rc=$?
n "a complete skill named in AGENTS.md passes" 'good/SKILL.md' "$out"
t "a missing description fails, naming the file" 'ERROR .*nodesc/SKILL.md: no description' "$out"
t "a name that differs from its directory fails" 'ERROR .*renamed/SKILL.md: name "other-name" differs from its directory "renamed"' "$out"
t "a skill no always-on instruction names fails" 'ERROR .*unnamed/SKILL.md: no always-on instruction \(AGENTS.md, CLAUDE.md\) names "unnamed"' "$out"
[ "$rc" -ne 0 ] && echo "ok - failures exit non-zero" || { echo "not ok - failures exit non-zero"; fails=$((fails+1)); }
out=$(bash "$LINT" . 2>&1); rc=$?
t "petals itself passes" '^ok: [0-9]+ skill' "$out"
[ "$rc" -eq 0 ] && echo "ok - petals itself exits zero" || { echo "not ok - petals itself exits zero ($out)"; fails=$((fails+1)); }
echo; echo "$fails failure(s)"; exit "$fails"
