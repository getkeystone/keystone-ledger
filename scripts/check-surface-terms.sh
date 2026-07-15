#!/usr/bin/env bash
#
# check-surface-terms.sh — generalized-surface guard (fail-closed).
#
# Blocks raw job-search "apparatus" surface names (Post #1, cover letter, resume,
# blurb, private pass, high-stakes send — see scripts/surface-terms.txt) from
# re-entering the PUBLIC claims surface. The public claims-matrix records WHERE a
# claim appears using a generalized label ("application materials"); this guard
# fails the push if a raw surface name regresses in.
#
# Additive sibling to sanitize-check.sh (which scans README/PUBLIC_PROOF for
# retired CLAIM strings). This one scans the claims-matrix itself for raw SURFACE
# names. Prevention only — it neither rewrites history nor judges any claim.
#
# Usage:
#   scripts/check-surface-terms.sh [target ...]
#   # default targets (repo root): docs/claims-matrix.md  README.md  PUBLIC_PROOF_INDEX.md
#
# Exit: 0 = clean · 1 = a raw surface term was found · 2 = term list missing.
# Runs standalone (manual pre-publish check) and is invoked by the pre-push hook.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
TERMS="$HERE/surface-terms.txt"

# Fail closed: no term list means the control cannot run.
if [[ ! -f "$TERMS" ]]; then
  echo "check-surface-terms: term list not found at $TERMS — refusing (fail-closed)." >&2
  exit 2
fi

# Default public claims surfaces; override by passing explicit paths.
if [[ "$#" -gt 0 ]]; then
  targets=("$@")
else
  targets=("$ROOT/docs/claims-matrix.md" "$ROOT/README.md" "$ROOT/PUBLIC_PROOF_INDEX.md")
fi

# Scan only targets that exist.
scan=()
for t in "${targets[@]}"; do
  [[ -f "$t" ]] && scan+=("$t")
done
if [[ "${#scan[@]}" -eq 0 ]]; then
  echo "check-surface-terms: no target files to scan — nothing to check." >&2
  exit 0
fi

hit=0
while IFS= read -r term; do
  [[ -z "$term" || "$term" == \#* ]] && continue
  # Fixed-string, case-insensitive, whole-word so "resume" does not match "presume".
  if grep -Fwin -- "$term" "${scan[@]}" 2>/dev/null; then
    echo "check-surface-terms: raw surface term \"$term\" found on the public claims surface — fail-closed." >&2
    hit=1
  fi
done < "$TERMS"

if [[ "$hit" -ne 0 ]]; then
  echo "" >&2
  echo "SURFACE GATE FAILED: generalize the surface description (e.g. \"application materials\") before publishing." >&2
  exit 1
fi

echo "check-surface-terms: clean — no raw surface terms on the public claims surface."
