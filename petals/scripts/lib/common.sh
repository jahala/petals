#!/usr/bin/env bash
# petals/scripts/lib/common.sh — shared helpers for all petals scripts.

# The directory the caller ran the script from. Scripts move to the project
# root after sourcing this file, so a path the caller typed is resolved
# against this directory first.
CALLER_PWD="$PWD"

# Resolve a path the caller typed, relative to where they called from.
from_caller() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *)  printf '%s/%s\n' "$CALLER_PWD" "$1" ;;
  esac
}

# Same, for a source that may be a URL or a remote shorthand: resolve it only
# when it names something that exists from the caller's directory.
from_caller_if_exists() {
  case "$1" in
    /*|*://*|git@*) printf '%s\n' "$1" ;;
    *) if [[ -e "$CALLER_PWD/$1" ]]; then printf '%s/%s\n' "$CALLER_PWD" "$1"; else printf '%s\n' "$1"; fi ;;
  esac
}

# Walk up from a directory (default: $PWD) looking for the project root.
# A project root is a directory containing .petalsrc or .brand/.
# Prints the absolute path and returns 0, or returns 1 if not found.
find_project_root() {
  local dir="${1:-$PWD}"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.petalsrc" ]] || [[ -d "$dir/.brand" ]]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

# Every custom property colors.md's CSS blocks declare (inside code fences),
# one line each: "<selector>\t<name>\t<value>". The selector is the rule's own
# selector with each enclosing rule or at-rule before it, whitespace collapsed:
# ":root", ".dark", or "@media (prefers-color-scheme: dark) { :root }" for a
# rule nested in another. A block petals cannot read prints one line that
# starts with "!" and says why. brand_prefix and brand_dark_selector read
# these lines; nothing else parses colors.md's CSS.
brand_css_props() {
  awk -v file="$1" '
    /^[ \t]*```/ { if (infence) props(text); text = ""; infence = !infence; next }
    infence { text = text $0 "\n" }
    END { if (infence) props(text) }
    function norm(s) { gsub(/[ \t\n]+/, " ", s); gsub(/^ | $/, "", s); return s }
    function props(t,   n, tok, i, c, d, acc) {
      gsub(/\/\*([^*]|\*+[^*\/])*\*+\//, "", t)
      gsub(/[{};]/, "\034&\034", t)
      n = split(t, tok, "\034"); d = 0; acc = ""
      for (i = 1; i <= n; i++) {
        c = tok[i]
        if (c == "{") { d++; sel[d] = norm(acc); acc = "" }
        else if (c == "}") {
          decl(acc, d); acc = ""
          if (d == 0) { print "!a CSS block in " file " closes a brace it never opened"; return }
          d--
        }
        else if (c == ";") { decl(acc, d); acc = "" }
        else acc = acc c
      }
      if (d > 0) print "!the " sel[d] " block in " file " opens a brace it never closes"
    }
    function decl(a, d,   name, value, chain, j) {
      if (d == 0 || !match(a, /^[ \t\n]*--[A-Za-z0-9_-]+[ \t\n]*:/)) return
      name = substr(a, RSTART, RLENGTH); sub(/:$/, "", name); name = norm(name)
      value = norm(substr(a, RSTART + RLENGTH))
      chain = sel[1]
      for (j = 2; j <= d; j++) chain = chain " { " sel[j]
      for (j = 2; j <= d; j++) chain = chain " }"
      if (sel[d] ~ /^@/) { print "!" file " declares " name " in " chain " outside any selector"; return }
      print chain "\t" name "\t" value
    }' "$1"
}

# The custom-property prefix a brand declares, such as --pp- or --acme-: the
# one "--<word>-" every property in colors.md's own CSS blocks (inside code
# fences, brand_css_props) starts with. Every script reads the prefix here
# and nowhere else. Prints the prefix and returns 0; when colors.md is
# missing, declares no properties, or mixes prefixes, prints why and returns
# 1. It never guesses one.
brand_prefix() {
  local colors="$1"
  [[ -f "$colors" ]] || { echo "$colors is missing, so the brand's token prefix is unknown"; return 1; }
  brand_css_props "$colors" | awk -F'\t' -v file="$colors" '
    /^!/ { next }
    {
      p = match($2, /^--[A-Za-z0-9]+-/) ? substr($2, 1, RLENGTH) : $2
      if (!(p in seen)) { seen[p] = 1; n++; list = list (n > 1 ? ", " : "") p }
    }
    END {
      if (n == 0) { print file " declares no custom properties in a CSS :root block, so the brand\047s token prefix is unknown"; exit 1 }
      if (n > 1) { print file " uses more than one token prefix in its CSS blocks (" list "); a brand declares one, such as --acme-"; exit 1 }
      print list
    }'
}

# The brand's own dark-theme selector: the selector of the block in
# colors.md's CSS that overrides the :root colours, as the brand writes it
# (brand_css_props): [data-theme="dark"], .dark, :root.dark, or
# "@media (prefers-color-scheme: dark) { :root }". No selector is assumed:
# a brand whose only block is :root has no dark theme. Every script that
# reads or writes the brand's dark theme asks here.
# Prints one selector per line (none without a dark theme) and returns 0.
# Two dark blocks under different selectors with the same declarations are
# one dark theme, and both are printed. Returns 1 and prints why, naming the
# selectors, when two dark blocks declare different values or a block cannot
# be read: which one is the dark theme is never guessed. A missing colors.md
# has no dark theme.
brand_dark_selector() {
  [[ -f "$1" ]] || return 0
  brand_css_props "$1" | awk -F'\t' -v file="$1" '
    /^!/ { bad = bad (bad != "" ? "; " : "") substr($0, 2); next }
    $1 == ":root" { next }
    {
      if (!($1 in at)) { at[$1] = ++n; sel[n] = $1 }
      k = $2 ": " tolower($3)
      if (!(($1, k) in has)) { has[$1, k] = 1; cnt[$1]++; keys[$1] = keys[$1] "\036" k }
    }
    END {
      if (bad != "") { print bad ", so the dark theme cannot be read"; exit 1 }
      for (i = 2; i <= n; i++) {
        same = (cnt[sel[i]] == cnt[sel[1]])
        m = split(substr(keys[sel[1]], 2), ks, "\036")
        for (j = 1; same && j <= m; j++) if (!((sel[i], ks[j]) in has)) same = 0
        if (!same) {
          list = sel[1]; for (j = 2; j <= n; j++) list = list (j < n ? ", " : " and ") sel[j]
          print file " has " n " dark blocks with different values (" list "); petals reads one dark theme and does not guess which. Keep one, or give them the same values"
          exit 1
        }
      }
      for (i = 1; i <= n; i++) print sel[i]
    }'
}
