#!/usr/bin/env bash
#
# sanitize-check.sh — Keystone ledger publication sanitizer (EX-008, fail-closed).
#
# Scans EVERY tracked file (git ls-files) for any retired/forbidden string, so a
# retired claim or a leaked internal identifier cannot regress into the repo.
# Two passes:
#   1. Literal terms from scripts/sanitize-terms.txt (grep -F), one per line;
#      blank lines and lines starting with # are skipped.
#   2. Tailnet IP regex (grep -E) — 100.64.0.0/10 CGNAT / Tailscale range.
# Any hit in either pass prints filename:line and exits non-zero. Judging whether
# a NEW claim's evidence is real stays human (docs/claims-matrix.md).
#
# Usage: scripts/sanitize-check.sh
# Exit codes: 0 = clean · 1 = a forbidden term/IP was found · 2 = term list missing.
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

cd "$ROOT"

# All tracked files (NUL-delimited to survive odd paths), minus a small skip-list.
# Skip files that define or document the denylist itself — they legitimately
# contain the very terms they govern, so scanning them is a guaranteed self-match,
# not a leak:
#   scripts/sanitize-terms.txt  — the denylist (lists every term by definition)
#   scripts/sanitize-check.sh   — this guard (embeds the tailnet regex in its docs)
#   docs/claims-matrix.md       — names retired claims in order to govern them
# Nothing else is excluded: milestones/, updates/, artifacts/, index/ are all scanned.
mapfile -d '' files < <(git ls-files -z | grep -zvE '^(scripts/sanitize-terms\.txt|scripts/sanitize-check\.sh|docs/claims-matrix\.md)$')
if [[ "${#files[@]}" -eq 0 ]]; then
  echo "sanitize-check: no tracked files to scan — nothing to check." >&2
  exit 0
fi

hit=0

# ── Pass 1: literal retired/forbidden terms ──────────────────────────────────
while IFS= read -r term; do
  [[ -z "$term" || "$term" == \#* ]] && continue
  if grep -Fn -- "$term" "${files[@]}" 2>/dev/null; then
    echo "sanitize-check: forbidden term \"$term\" found — fail-closed." >&2
    hit=1
  fi
done < "$TERMS"

# ── Pass 2: tailnet IPs (100.64.0.0/10) ──────────────────────────────────────
tailnet='100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.[0-9]+\.[0-9]+'
if grep -En -- "$tailnet" "${files[@]}" 2>/dev/null; then
  echo "sanitize-check: tailnet IP (100.64.0.0/10) found — fail-closed." >&2
  hit=1
fi

if [[ "$hit" -ne 0 ]]; then
  echo "" >&2
  echo "SANITIZE GATE FAILED: remove or rephrase the item(s) above before publishing." >&2
  exit 1
fi

echo "sanitize-check: clean — no forbidden terms or tailnet IPs in tracked files."
