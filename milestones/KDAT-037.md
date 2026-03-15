# KDAT-037 — Audit Verifier: Redact Env Var Names from Output

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`tools/verify_audit_export.py` no longer emits sensitive environment variable
names (e.g., `AUDIT_HMAC_KEY`) in its output. A pytest regression suite
(`tests/test_verify_audit_export.py`) asserts that seven forbidden patterns
never appear in verifier output regardless of HMAC key presence or absence.

---

## What this milestone proves

- `tools/verify_audit_export.py`: HMAC key presence is now reported as
  `"HMAC recomputation: enabled (key present)"` rather than
  `"AUDIT_HMAC_KEY: set (64 bytes)"` — the env var name is no longer printed
- `tests/test_verify_audit_export.py` (new, 260 lines): pytest regression suite,
  class `TestNoSecretEnvNamesInOutput` with 7 tests:
  - `test_no_forbidden_patterns_with_key_set_via_env`: confirms forbidden patterns
    absent when HMAC key provided via environment
  - `test_no_forbidden_patterns_with_key_via_cli`: same with `--hmac-key` CLI arg
  - `test_no_forbidden_patterns_without_key`: confirms forbidden patterns absent
    when no HMAC key is set
  - `test_hmac_enabled_message_with_key`: confirms the new "HMAC recomputation:
    enabled (key present)" text appears when key is set
  - `test_hmac_disabled_message_without_key`: confirms "disabled" text appears
    when key is absent
  - `test_pass_with_correct_key`: verifier exits 0 with a valid bundle + key
  - `test_pass_without_key`: verifier exits 0 without a key
- Forbidden patterns covered: `AUDIT_HMAC_KEY`, `CLIENT_SECRET`, `RESET_TOKEN`,
  `CLOUDFLARE_ACCESS_CLIENT`, `NTFY_TOKEN`
- `docs/audit-export.md`: updated example output to reflect the new HMAC
  recomputation message

---

## What this milestone does NOT prove

- That all sensitive variable names are covered in all future code paths
  (tests cover the known set of five patterns)
- Runtime security of HMAC key material in process memory or kernel logs
- Log aggregation pipeline (output is stdout only)

---

## Public-safe claims

"The audit bundle verifier does not print sensitive environment variable names
in its output. A pytest regression suite asserts that five forbidden patterns
(`AUDIT_HMAC_KEY`, `CLIENT_SECRET`, `RESET_TOKEN`, `CLOUDFLARE_ACCESS_CLIENT`,
`NTFY_TOKEN`) are absent from verifier output in all tested configurations
(key via env, key via CLI, no key)."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `94e71ec` | feat(kdat-037): redact env var names from audit verifier logs |
| Verifier patch | `tools/verify_audit_export.py` | HMAC message no longer names the env var |
| Regression tests | `tests/test_verify_audit_export.py` | 7 pytest tests; 260 lines |
| Docs | `docs/audit-export.md` | Updated example output |

---

## Verification and tests

**`tests/test_verify_audit_export.py`** — 7 assertions:

| Test | Assertion |
|------|-----------|
| `test_no_forbidden_patterns_with_key_set_via_env` | No forbidden pattern in output (key via env) |
| `test_no_forbidden_patterns_with_key_via_cli` | No forbidden pattern in output (key via CLI) |
| `test_no_forbidden_patterns_without_key` | No forbidden pattern in output (no key) |
| `test_hmac_enabled_message_with_key` | "HMAC recomputation: enabled (key present)" in output |
| `test_hmac_disabled_message_without_key` | "disabled" in output when no key |
| `test_pass_with_correct_key` | Verifier exits 0 with valid bundle + key |
| `test_pass_without_key` | Verifier exits 0 without key |

---

## Known limitations and caveats

- Tests build synthetic audit bundles in `tempfile.TemporaryDirectory`; they
  do not test against a live running stack.
- Forbidden patterns are a fixed list; any new secret variable introduced in
  future code must be added to `FORBIDDEN_PATTERNS` and covered by a new test.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-15.

| Commit | Purpose |
|--------|---------|
| `94e71ec` | Delivery: verifier redaction + pytest regression suite |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Run the regression tests:
python3 -m pytest tests/test_verify_audit_export.py -v
```
