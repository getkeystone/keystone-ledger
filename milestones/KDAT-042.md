# KDAT-042 — Ops Status Snapshot (Text + JSON)

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/ops-status.sh` produces a deterministic 8-section human-readable
ops status report covering maintenance, smoke checks, resource sentinel, timer
health, repo state, release inputs, and ntfy. `scripts/ops-status.json.sh`
emits the same data as machine-readable JSON without secret values. A hardened
oneshot systemd unit (`ops-status.service`) and idempotent installer are
provided. Smoke scripts gain a `SMOKE_SUMMARY_ONLY=1` mode for embedded
reporting.

---

## What this milestone proves

- `scripts/ops-status.sh`: 8-section status report; exits 0 (PASS) / 1 (FAIL)
  / 2 (WARN); sections: maintenance · public path (CF smoke) · origin smoke ·
  resource sentinel · timer health table · repo state · release inputs · ntfy
- `scripts/ops-status.json.sh`: identical data as JSON; never includes
  secret values in payload
- `scripts/smoke-cf.sh`, `scripts/smoke-origin.sh`: `SMOKE_SUMMARY_ONLY=1`
  mode added for embedded use in ops-status
- `scripts/_deploy_env.sh`: `KS_ENV_FILE` override added for test isolation
- `docs/systemd/ops-status.service`: hardened oneshot unit (no timer);
  `ProtectHome=read-only`; `ReadWritePaths=%h/.cache/keystone`
- `scripts/install-ops-status-service.sh`: idempotent service installer
- `scripts/test_kdat042_ops_status.sh` — **19/19 PASS**

---

## What this milestone does NOT prove

- Automatic periodic scheduling (no timer unit — service is on-demand or
  wired by the operator)
- Alerting on ops-status FAIL (no ntfy integration in this milestone;
  KDAT-043 adds drift alerting)
- That all possible failure modes surface in the status report

---

## Public-safe claims

"A single command (`bash scripts/ops-status.sh`) produces a structured
8-section ops status report covering maintenance state, smoke checks, resource
sentinel, timer health, repo cleanliness, release inputs, and ntfy
configuration. A JSON variant is available for machine consumption. 19/19
tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `1f1511c` | feat(kdat-042): ops status snapshot (text + json) |
| Status script | `scripts/ops-status.sh` | 8 sections; exits 0/1/2 |
| JSON variant | `scripts/ops-status.json.sh` | machine-readable; no secrets |
| Smoke summary mode | `scripts/smoke-cf.sh`, `scripts/smoke-origin.sh` | `SMOKE_SUMMARY_ONLY=1` |
| Service unit | `docs/systemd/ops-status.service` | hardened oneshot |
| Installer | `scripts/install-ops-status-service.sh` | idempotent |
| Regression tests | `scripts/test_kdat042_ops_status.sh` | 19/19 PASS |

---

## Verification and tests

**`scripts/test_kdat042_ops_status.sh`** — 19/19 PASS

Tests cover: isolated env file, section headings present, exit codes (0/1/2),
JSON schema shape, no secret values in JSON output, `SMOKE_SUMMARY_ONLY=1`
behaviour, `KS_ENV_FILE` override.

---

## Known limitations and caveats

- No periodic timer — the service is oneshot/on-demand. Operators must schedule
  or invoke manually.
- JSON output is a snapshot; it does not persist history.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-15.

| Commit | Purpose |
|--------|---------|
| `1f1511c` | Delivery: ops-status.sh + ops-status.json.sh + test script |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat042_ops_status.sh
```
