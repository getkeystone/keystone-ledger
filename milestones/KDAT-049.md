# KDAT-049 — Pilot Health Pack Bundle (Redacted)

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/pilot-health-pack.sh` generates a redacted, portable diagnostic
bundle (`tar.gz` + `.sha256`) suitable for sharing with support or for
offline review without leaking secrets. The bundle contains ops snapshots,
systemd unit logs, version metadata, and a per-file checksum manifest. A
Python secret scan aborts bundle creation if any forbidden pattern is found.

---

## What this milestone proves

- `scripts/pilot-health-pack.sh`: single-command bundle generator;
  KDAT-041 maintenance skip + KDAT-038 lock before any env/network;
  `PUBLIC_DEMO_MODE` guard unchanged
- **Bundle contents** (schema `keystone-health-pack/v1`):
  - `pack/manifest.json`: schema, host, timestamp, tool versions, per-check status
  - `pack/snapshots/`: `ops-status.json`, `ops-status.txt`, `baseline-check.json`,
    `schema-contract.txt`, `release-inputs.txt`
  - `pack/logs/`: last 200 lines from 6 systemd units
  - `pack/metadata/`: `versions.txt`, `timers.txt`, `containers.txt`,
    `ports.txt`, `checksums.txt` (sha256 per file)
- **Secret scan**: Python validates every pack file for forbidden literal
  substrings before tar creation; scan failure aborts with boxed remediation
  block and no tarball produced
- Forbidden patterns: `CF-Access-Client-Secret` values, credential `key=value`
  assignments, JWT three-segment token patterns, long hex strings outside
  sha256 context
- Output: `~/keystone/health-packs/` (override: `KS_HEALTH_PACK_DIR`);
  sibling `.sha256` file alongside each tarball
- Exit codes: 0=PASS/WARN, 1=FAIL or scan triggered, 2=hard preflight,
  maintenance/lock=exit 0
- `scripts/test_kdat049_health_pack.sh` — **52/52 PASS**:
  - T1: maintenance skip → exit 0, `[SKIP]`, no tarball
  - T2: lock skip → exit 0, `[SKIP]`, no tarball
  - T3: normal run → tarball + `.sha256`, 17 required paths verified,
    manifest valid JSON with all required fields + checks keys
  - T4: `KS_TEST_INJECT_SECRET=1` → exit 1 + remediation box, no tarball
  - T5: `KS_TEST_INJECT_LONGHEX=1` → exit 1, `long hex` reason in output
  - T6: `checksums.txt` (sha256-labelled entries) passes scan; PASS confirmed

---

## What this milestone does NOT prove

- Exhaustive coverage of all possible secret patterns (scan covers a defined
  set of forbidden patterns; new patterns require explicit addition)
- That bundle contents are semantically correct (checks snapshot tools are
  called; does not validate snapshot accuracy)
- Automated delivery to support (bundle is local; delivery is manual)

---

## Public-safe claims

"A single command generates a redacted, portable diagnostic bundle with ops
snapshots, systemd logs, version metadata, and per-file checksums. A Python
secret scan validates every file before tar creation; any forbidden pattern
aborts with a remediation block and no tarball is produced. 52/52 tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `79d74c5` | feat(kdat-049): pilot health pack bundle (redacted) |
| Health pack script | `scripts/pilot-health-pack.sh` | tar.gz + .sha256; secret scan; 17 required paths |
| Regression tests | `scripts/test_kdat049_health_pack.sh` | 52/52 PASS |
| Docs | `docs/public-access.md` | KDAT-049 section with usage + bundle structure |

---

## Verification and tests

**`scripts/test_kdat049_health_pack.sh`** — 52/52 PASS

| Test | Assertion |
|------|-----------|
| T1 | Maintenance skip → exit 0, [SKIP], no tarball |
| T2 | Lock skip → exit 0, [SKIP], no tarball |
| T3 | Normal run → tarball + .sha256, 17 paths, valid manifest JSON |
| T4 | `KS_TEST_INJECT_SECRET=1` → exit 1, remediation box, no tarball |
| T5 | `KS_TEST_INJECT_LONGHEX=1` → exit 1, reason in output |
| T6 | sha256-labelled entries in checksums.txt pass scan |

---

## Known limitations and caveats

- Secret scan covers a defined set of patterns; new secret types must be
  explicitly added to `tools/scan_pack_secrets.py` (introduced in KDAT-050).
- `pack/logs/` captures last 200 lines only; older journal entries are not
  included.
- Bundle delivery to support is manual; no automated upload path.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16.

| Commit | Purpose |
|--------|---------|
| `79d74c5` | Delivery: pilot-health-pack.sh + 52-test suite + docs |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat049_health_pack.sh
```
