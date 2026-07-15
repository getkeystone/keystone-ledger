#!/usr/bin/env bash
#
# sanitize-check.sh — Keystone ledger publication sanitizer (EX-008, fail-closed).
#
# Greps the externally-citable surfaces for any retired/forbidden claim string
# listed in scripts/sanitize-terms.txt (data only). Any hit exits non-zero, so a
# retired claim cannot regress into public copy. This is the mechanizable part of
# claims enforcement; judging whether a NEW claim's evidence is real stays human
# (the operator sets each row's status in docs/claims-matrix.md).
#
# Usage:
#   scripts/sanitize-check.sh [target ...]
#   # default targets (repo root): README.md  PUBLIC_PROOF_INDEX.md
#
# Exit codes: 0 = clean · 1 = a retired term was found · 2 = term list missing.
#
# Runs standalone (manual pre-publish check) and is invoked by the pre-push hook.
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
TERMS="$HERE/sanitize-terms.txt"

# Fail closed: no term list means the control cannot run.
if [[ ! -f "$TERMS" ]]; then
  echo "sanitize-check: term list not found at $TERMS — refusing (fail-closed)." >&2
  exit 2
fi

# Default citable surfaces; override by passing explicit paths.
if [[ "$#" -gt 0 ]]; then
  targets=("$@")
else
  targets=("$ROOT/README.md" "$ROOT/PUBLIC_PROOF_INDEX.md")
fi

# Scan only targets that exist (a citable surface may not be present yet).
scan=()
for t in "${targets[@]}"; do
  [[ -f "$t" ]] && scan+=("$t")
done
if [[ "${#scan[@]}" -eq 0 ]]; then
  echo "sanitize-check: no target files to scan — nothing to check." >&2
  exit 0
fi

hit=0
while IFS= read -r term; do
  [[ -z "$term" || "$term" == \#* ]] && continue
  if grep -Fn -- "$term" "${scan[@]}" 2>/dev/null; then
    echo "sanitize-check: retired claim \"$term\" found on a citable surface — fail-closed." >&2
    hit=1
  fi
done < "$TERMS"

if [[ "$hit" -ne 0 ]]; then
  echo "" >&2
  echo "SANITIZE GATE FAILED: remove or rephrase the retired claim(s) above before publishing." >&2
  exit 1
fi

echo "sanitize-check: clean — no retired claim strings on citable surfaces."
