# KDAT-029 — Resource Sentinel Timer

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

A host resource sentinel runs every 15 minutes via a systemd user-unit timer.
It checks six resource dimensions (disk, Docker storage, memory, CPU load,
container health), reports PASS/WARN/FAIL per check, and sends an ntfy alert
on any non-zero exit.

---

## What this milestone proves

- `scripts/resource-sentinel.sh`: six checks with configurable thresholds:
  - O1: disk `/` (WARN at `DISK_WARN_PCT` / FAIL at `DISK_FAIL_PCT`, defaults 85%/92%)
  - O2: disk `CORPUS_ROOT` (same thresholds)
  - O3: Docker storage total (images + containers + volumes + build cache); parsed
    via `docker system df --format '{{json .}}'`; WARN/FAIL thresholds in GB
  - O4: memory pressure via `/proc/meminfo` `MemAvailable` (% used vs total)
  - O5: 1-min loadavg / nproc (WARN/FAIL per core thresholds)
  - O6: `docker compose ps` — api + postgres must be `(healthy)`, web must be `Up`
  - All thresholds overridable via environment; exits 0=PASS / 1=FAIL / 2=WARN
- `scripts/resource-sentinel-with-alert.sh`: wraps sentinel; captures last
  140 lines of output; sends ntfy alert on exit ≠ 0; never prints secrets
- `docs/systemd/resource-sentinel.service`: hardened oneshot unit;
  `ExecStart=resource-sentinel-with-alert.sh`
- `docs/systemd/resource-sentinel.timer`: `OnCalendar=*:0/15`, `Persistent=true`
- `scripts/install-resource-sentinel-timer.sh`: idempotent installer; validates
  scripts; copies units; daemon-reload; enables and starts timer; prints next
  trigger and disable instructions
- `docs/public-access.md`: "Resource sentinel timer (KDAT-029)" section with
  check table, threshold variables, exit codes, manual run, log, disable

Delivery commit message states: "Verified: PASS 8/8 direct + systemd;
systemd-analyze verify clean; journal shows clear PASS/WARN/FAIL banners;
no secrets in output."

---

## What this milestone does NOT prove

- Automated CI verification of the timer firing (systemd timers cannot be
  fully exercised in a stateless CI runner)
- Threshold calibration for any specific production workload
- Multi-host resource monitoring or aggregation
- Pager-duty or on-call routing (ntfy only)

---

## Public-safe claims

"A host resource sentinel runs every 15 minutes via a systemd user-unit timer.
It checks disk usage (root and corpus), Docker storage, memory pressure,
CPU load, and container health against configurable thresholds. A wrapper
sends an ntfy alert on WARN or FAIL exit. No secrets appear in log output."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `e6baf7a` | feat(ops): resource sentinel timer + disk/memory/load alerts |
| Sentinel script | `scripts/resource-sentinel.sh` | 6 checks; 268 lines |
| Alert wrapper | `scripts/resource-sentinel-with-alert.sh` | ntfy on non-zero exit |
| Systemd service | `docs/systemd/resource-sentinel.service` | Hardened oneshot unit |
| Systemd timer | `docs/systemd/resource-sentinel.timer` | Every 15 min, Persistent=true |
| Installer | `scripts/install-resource-sentinel-timer.sh` | Idempotent |
| Docs | `docs/public-access.md` | "Resource sentinel timer (KDAT-029)" section |

---

## Verification

Delivery commit states PASS 8/8 (direct + systemd); `systemd-analyze verify`
clean; journal confirmed structured PASS/WARN/FAIL output with no secret leakage.

No dedicated structural verification script (on par with `test_kdat026_timer.sh`)
exists yet. The 8-assertion count is from inline verification at delivery time.

---

## Known limitations and caveats

- No committed regression test script. Inline delivery verification (PASS 8/8)
  is the primary evidence.
- Timer cannot be fully exercised in a stateless CI environment.
- Thresholds are defaults calibrated for the host-primary deployment; operators
  should review before enabling on any other host.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `e6baf7a` | Delivery: sentinel, alert wrapper, systemd units, installer, docs |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Manual run:
bash scripts/resource-sentinel.sh

# Timer status:
systemctl --user list-timers resource-sentinel.timer --no-pager

# Recent journal:
journalctl --user -u resource-sentinel.service -n 50 --no-pager
```
