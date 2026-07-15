#!/usr/bin/env bash
#
# verify-claims-matrix.sh — pre-publish gate for the Keystone claims matrix.
#
# Reads docs/claims-matrix.md and FAILS (exit 1) if any claim row carries a
# status that is not OK. This is the mechanical form of governance red line 4:
# never publish a claim whose proof does not resolve.
#
# Usage:
#   scripts/verify-claims-matrix.sh [path/to/claims-matrix.md]
#
# Wire this into the publish path (and, ideally, CI) so a BROKEN / UNSOURCED /
# CHECK / STALE claim cannot ship unnoticed. A non-OK row does not always mean
# "do not publish" — it means "resolve, soften, remove, or consciously waive
# this claim before publishing," which is exactly the decision this gate forces.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATRIX="${1:-$HERE/../docs/claims-matrix.md}"

if [[ ! -f "$MATRIX" ]]; then
  echo "FAIL: claims matrix not found at: $MATRIX" >&2
  exit 2
fi

fail=0
in_table=0

while IFS= read -r line; do
  # Only markdown table rows.
  [[ "$line" == \|* ]] || { in_table=0; continue; }
  # Separator row (|---|---|): marks the start of a table body.
  if [[ "$line" =~ ^\|[[:space:]]*:?-{2,} ]]; then in_table=1; continue; fi
  # Header row (contains "Claim").
  if [[ "$line" == *"| Claim "* || "$line" == *"|Claim"* ]]; then in_table=0; continue; fi
  [[ "$in_table" -eq 1 ]] || continue

  # Status = last non-empty cell; strip markdown bold and whitespace; first token.
  status_cell="$(printf '%s\n' "$line" | awk -F'|' '{
    for (i=NF; i>=1; i--) { gsub(/^[ \t]+|[ \t]+$/, "", $i); if ($i != "") { print $i; break } }
  }')"
  token="$(printf '%s\n' "$status_cell" | sed 's/\*//g' | awk '{print $1}')"
  claim="$(printf '%s\n' "$line" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')"

  case "$token" in
    OK|OK,|OK.|OK—|"OK,and") : ;;                           # pass
    STALE|STALE-ish|BROKEN|UNSOURCED|CHECK|FIXING)
      printf 'NON-OK [%s]: %s\n' "$token" "$claim" >&2
      fail=1 ;;
    *) : ;;                                                  # not a status cell
  esac
done < "$MATRIX"

if [[ "$fail" -ne 0 ]]; then
  echo "" >&2
  echo "GATE FAILED: one or more cited claims are not OK." >&2
  echo "Resolve, soften, remove, or consciously waive each before publishing." >&2
  exit 1
fi

echo "claims-matrix gate: all claim rows OK. Clear to publish."
