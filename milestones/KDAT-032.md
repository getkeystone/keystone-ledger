# KDAT-032 — Audit Export + Offline Verifier

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

A tamper-evident audit bundle can be exported to a tar.gz archive containing
JSONL data files and a manifest with per-file SHA-256 checksums and HMAC
chain endpoints. A standalone Python verifier (`verify_audit_export.py`)
validates the manifest, file checksums, and audit log HMAC chain offline
on a separate machine (host-restore). Smoke assertion O5 runs export + verify
as a regression gate.

---

## What this milestone proves

- `scripts/export-audit.sh`: exports `audit_log`, `operator_decisions`,
  `incident_cases`, `incident_case_queries`, `corpus_doc_events` to JSONL
  with deterministic ordering; writes `manifest.json` with sha256 per file,
  row counts, time window, and chain endpoints (`start_prev_hash`, `end_hash`);
  runs inline verifier and stores output as `verify_audit.txt`; bundles to tar.gz
- `tools/verify_audit_export.py` (standalone offline verifier):
  - Validates manifest schema and per-file sha256 checksums (exit 4 on tamper)
  - Walks audit_log chain link by link (exit 5 on chain break)
  - Recomputes HMAC `entry_hash` when `AUDIT_HMAC_KEY` is available
  - Verifies chain `start_prev_hash` and `end_hash` against manifest
  - Exit codes: 0=ok, 4=tamper, 5=chain break, 2=usage, 1=general fail
- `scripts/smoke-origin.sh` O5: runs `export-audit.sh --since 24` and
  checks verifier exits 0 (7/7 checks all PASS)
- `docs/audit-export.md` (new): export procedure, scp to host-restore,
  offline verify steps, exit code table, what is/is not proven

---

## What this milestone does NOT prove

- Real-time streaming or continuous audit export
- HMAC key escrow or multi-party key approval
- Long-term archive integrity (export is point-in-time)
- Integration with external SIEM or audit platforms
- Export of tables beyond the five covered

---

## Public-safe claims

"An audit bundle can be exported as a deterministic tar.gz archive with
JSONL data files and a manifest containing per-file SHA-256 checksums and
HMAC chain endpoints. A standalone Python verifier validates the manifest
and walks the audit log HMAC chain offline on a separate machine. Tamper
or chain-break exit codes are distinct (4 and 5 respectively). O5 in the
origin smoke suite gates against silent regressions."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `efbd335` | feat(kdat-032): audit export + offline verifier |
| Export script | `scripts/export-audit.sh` | JSONL + manifest + inline verify |
| Offline verifier | `tools/verify_audit_export.py` | Standalone; exit 4=tamper, 5=chain break |
| Smoke O5 | `scripts/smoke-origin.sh` | export + verify → must exit 0 |
| Docs | `docs/audit-export.md` | Procedure + exit code table |

---

## Verification and tests

**`scripts/smoke-origin.sh` O5**:

| # | Assertion |
|---|-----------|
| O5 | `export-audit.sh --since 24` + `verify_audit_export.py` → exit 0 |

Delivery commit states: 7/7 checks all PASS.

**`tests/test_verify_audit_export.py`** (added in KDAT-037):
- Regression tests for the verifier; see KDAT-037 for details.

---

## Known limitations and caveats

- HMAC chain validation requires `AUDIT_HMAC_KEY` to be set; without it
  the verifier performs structural and SHA-256 checks only.
- The O5 smoke check runs against the live stack; it requires a running
  api container with a populated audit_log table.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `efbd335` | Delivery: export script, offline verifier, smoke O5, audit-export.md |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Export last 24 hours and verify:
bash scripts/export-audit.sh --since 24

# Full origin smoke (includes O5):
bash scripts/smoke-origin.sh

# Offline verify a bundle on host-restore:
python3 tools/verify_audit_export.py /path/to/keystone-audit-*.tar.gz
```
