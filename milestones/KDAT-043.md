# KDAT-043 — Ops Baseline and Drift Detection

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/ops-baseline-save.sh` captures a normalised ops snapshot (stripping
volatile fields) as the authoritative baseline. `scripts/ops-baseline-check.sh`
compares the current normalised state to the baseline, reports changed fields
with FAIL/WARN/INFO severity, and exits 0/1/2. A hardened hourly timer
(`ops-baseline-check.timer`, `Persistent=true`) runs the check and sends an
ntfy alert on FAIL/WARN. Drift is detected and surfaced without needing to
diff raw logs.

---

## What this milestone proves

- `scripts/ops-baseline-save.sh`: collects normalised ops snapshot;
  strips volatile fields (`time_utc`, `host`, timer `next`/`last`, all
  `detail` strings); injects `publish_port`; writes versioned timestamped copy
  (chmod 600)
- `scripts/ops-baseline-check.sh`: compares current normalised state to
  baseline; reports changed fields with FAIL/WARN/INFO severity; exits
  0/1/2; supports `KS_CURRENT_SNAPSHOT_FILE` override for test isolation
- `scripts/ops-baseline-check-with-alert.sh`: wrapper with maintenance skip,
  env load, flock, ntfy alert on FAIL/WARN (no secret values in ntfy payload)
- `docs/systemd/ops-baseline-check.service` + `.timer`: hardened oneshot +
  hourly timer (`Persistent=true`, `RandomizedDelaySec=75`, `AccuracySec=1min`)
- `scripts/install-ops-baseline-check-timer.sh`: idempotent installer
- `scripts/test_kdat043_ops_baseline.sh` — **13/13 PASS** (no-drift, WARN,
  FAIL, skip scenarios)

---

## What this milestone does NOT prove

- Root-cause diagnosis of detected drift (check reports the field change;
  operator investigates)
- Multi-host baseline comparison (single-host only)
- That all ops-status fields are drift-significant (only non-volatile
  normalised fields are compared)

---

## Public-safe claims

"A saved baseline snapshot is compared hourly against the current ops state.
Changed fields are reported with severity (FAIL/WARN/INFO); a ntfy alert is
sent on FAIL or WARN. Volatile fields (timestamps, timer schedules) are
stripped before comparison to avoid false positives. 13/13 tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `a2cb823` | feat(kdat-043): ops baseline and drift detection |
| Save script | `scripts/ops-baseline-save.sh` | normalised snapshot; versioned copy; chmod 600 |
| Check script | `scripts/ops-baseline-check.sh` | FAIL/WARN/INFO per field; exits 0/1/2 |
| Alert wrapper | `scripts/ops-baseline-check-with-alert.sh` | ntfy on FAIL/WARN; no secrets in payload |
| Timer | `docs/systemd/ops-baseline-check.{service,timer}` | hourly; Persistent=true |
| Installer | `scripts/install-ops-baseline-check-timer.sh` | idempotent |
| Regression tests | `scripts/test_kdat043_ops_baseline.sh` | 13/13 PASS |
| Docs | `docs/public-access.md` | "Ops baseline + drift detection" section |

---

## Verification and tests

**`scripts/test_kdat043_ops_baseline.sh`** — 13/13 PASS

Tests cover: no-drift scenario (exit 0), single WARN field (exit 2), single
FAIL field (exit 1), ntfy payload contains no secret values, maintenance skip
fires before any comparison.

---

## Known limitations and caveats

- Baseline is a point-in-time snapshot; intentional config changes require
  re-saving the baseline to avoid false alarms.
- `publish_port` is injected at save time — port changes trigger a FAIL.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-15.

| Commit | Purpose |
|--------|---------|
| `a2cb823` | Delivery: ops-baseline-save/check + alert wrapper + hourly timer |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat043_ops_baseline.sh
```
