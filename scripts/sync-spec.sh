#!/usr/bin/env bash
# Sync the spec section of README.md from skills/pamcode/SKILL.md.
#
# The spec is the region between `<!-- spec-start -->` and `<!-- spec-end -->`
# in both files (markers included). The README region is replaced wholesale,
# so SKILL.md is the single source of truth.

set -euo pipefail

check_only=0
for arg in "$@"; do
  case "$arg" in
    --check) check_only=1 ;;
    *) echo "usage: $0 [--check]" >&2; exit 2 ;;
  esac
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill="$root/skills/pamcode/SKILL.md"
readme="$root/README.md"
start='<!-- spec-start -->'
end='<!-- spec-end -->'

for f in "$skill" "$readme"; do
  [ -f "$f" ] || { echo "error: missing $f" >&2; exit 1; }
  [ "$(grep -c -F "$start" "$f")" -eq 1 ] || { echo "error: expected exactly one '$start' in $f" >&2; exit 1; }
  [ "$(grep -c -F "$end" "$f")" -ge 1 ] || { echo "error: missing '$end' in $f" >&2; exit 1; }
done

tmp_spec="$(mktemp)"
tmp_readme="$(mktemp)"
trap 'rm -f "$tmp_spec" "$tmp_readme"' EXIT

# Extract the spec region (markers included) from the skill.
sed -n "/$start/,/$end/p" "$skill" > "$tmp_spec"

# Splice it into the readme, replacing the existing region.
awk -v spec_file="$tmp_spec" -v start="$start" -v end="$end" '
  BEGIN { while ((getline line < spec_file) > 0) spec[++n] = line }
  index($0, start) {
    for (i = 1; i <= n; i++) print spec[i]
    in_spec = 1
    next
  }
  in_spec && index($0, end) { in_spec = 0; next }
  in_spec { next }
  { print }
' "$readme" > "$tmp_readme"

# Sanity: the splice must not have dropped the markers.
[ "$(grep -c -F "$start" "$tmp_readme")" -eq 1 ] || { echo "error: splice failed" >&2; exit 1; }
[ "$(grep -c -F "$end" "$tmp_readme")" -ge 1 ] || { echo "error: splice failed" >&2; exit 1; }

if [ "$check_only" -eq 1 ]; then
  if cmp -s "$tmp_readme" "$readme"; then
    echo "spec is in sync"
    exit 0
  fi
  echo "spec is out of sync (run $0 to update)" >&2
  exit 1
fi

mv "$tmp_readme" "$readme"
echo "synced spec from $skill into $readme"
