# KDAT-050 — Health Pack Sanitization for CF Log Noise

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

Resolves two categories of false positives in the KDAT-049 secret scan when
running `pilot-health-pack.sh` on a live host: (1) `smoke-cf.sh` diagnostic
messages that contain literal forbidden env var names and (2) CF Access 302
Location headers containing long base64url query parameters matching the JWT
three-segment pattern. Two complementary mitigations are introduced:
`tools/sanitize_pack_text.py` strips/replaces before the scan, and
`smoke-cf.sh` is hardened to never emit forbidden var names in its output.

---

## What this milestone proves

- `tools/sanitize_pack_text.py`: line-preserving sanitizer; strips CF Access
  URL query strings (`?REDACTED`); replaces forbidden env var names with
  neutral labels; used by `pilot-health-pack.sh` before the secret scan step
- `tools/scan_pack_secrets.py`: inline Python3 scan block extracted into a
  standalone tool with a proper CLI interface; called by `pilot-health-pack.sh`
  instead of the previous inline heredoc
- `scripts/pilot-health-pack.sh` updated: sanitize step added before scan;
  calls `tools/scan_pack_secrets.py`
- `scripts/smoke-cf.sh` hardened: forbidden var names in T6 diagnostic output
  replaced with neutral labels; `_cf_loc_redact()` helper added; applied to
  all `location:` info lines
- `scripts/test_kdat050_health_pack_sanitization.sh` — **18/18 PASS**:
  - T1: `sanitize_pack_text.py` strips CF Access redirect query strings
  - T2: `sanitize_pack_text.py` replaces forbidden env var names
  - T3: `scan_pack_secrets.py` passes on clean pack fixture
  - T4: `scan_pack_secrets.py` detects forbidden secret in dirty pack
  - T5: `smoke-cf.sh` diagnostic messages no longer emit forbidden var names
- KDAT-049 regression: **52/52 PASS** (unchanged after this refactor)

---

## What this milestone does NOT prove

- That all possible CF Access URL formats are sanitized (sanitizer covers
  the `?<query>` pattern; fragment identifiers are not addressed)
- That `scan_pack_secrets.py` CLI interface is stable (tool is internal)
- Log sanitization at collection time (sanitization is applied post-collection
  before scan, not at the journal-capture stage)

---

## Public-safe claims

"Two false-positive categories in the health pack secret scan are eliminated:
CF Access redirect query strings are stripped before scanning, and `smoke-cf.sh`
no longer emits forbidden env var names in diagnostic output. The standalone
`scan_pack_secrets.py` tool replaces the inline scan block. 18/18 tests pass;
KDAT-049 remains 52/52 PASS."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `de32033` | feat(kdat-050): health pack sanitization for CF log noise |
| Sanitizer | `tools/sanitize_pack_text.py` | strips query strings; replaces forbidden var names |
| Secret scanner | `tools/scan_pack_secrets.py` | extracted from inline block; CLI interface |
| Health pack update | `scripts/pilot-health-pack.sh` | sanitize before scan; calls scan_pack_secrets.py |
| smoke-cf hardening | `scripts/smoke-cf.sh` | `_cf_loc_redact()`; no forbidden names in output |
| Regression tests | `scripts/test_kdat050_health_pack_sanitization.sh` | 18/18 PASS |
| Docs | `docs/public-access.md` | KDAT-050 section documenting both mitigations |

---

## Verification and tests

**`scripts/test_kdat050_health_pack_sanitization.sh`** — 18/18 PASS

| Test | Assertion |
|------|-----------|
| T1 | `sanitize_pack_text.py` strips `?<query>` from CF Access redirects |
| T2 | `sanitize_pack_text.py` replaces forbidden env var names with neutral labels |
| T3 | `scan_pack_secrets.py` passes on clean fixture |
| T4 | `scan_pack_secrets.py` detects forbidden secret in dirty fixture |
| T5 | `smoke-cf.sh` diagnostic output contains no forbidden var names |

---

## Known limitations and caveats

- Sanitization is applied post-collection; if new log sources emit forbidden
  patterns they must be covered by additions to `sanitize_pack_text.py`.
- Fragment identifiers in CF Access URLs are not sanitized (not observed in
  practice on host-primary).

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16.

| Commit | Purpose |
|--------|---------|
| `de32033` | Delivery: sanitize_pack_text.py + scan_pack_secrets.py + smoke-cf hardening + 18-test suite |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat050_health_pack_sanitization.sh
# Confirm KDAT-049 still passes:
bash scripts/test_kdat049_health_pack.sh
```
