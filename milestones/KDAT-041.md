# KDAT-041 — Maintenance Window Skip + Timer Jitter

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/_maintenance.sh` provides a flag-file-based maintenance window
mechanism. Five periodic job wrappers check the flag before any API call,
curl invocation, or env loading; if the flag is present they exit 0 with a
`[SKIP] <job>: maintenance window active` log line. `restore-drill-remote.sh`
enters a maintenance window automatically while it runs and clears it on
exit. Three timers receive `RandomizedDelaySec=75` to prevent the 15-minute
timer stampede.

---

## What this milestone proves

- `scripts/_maintenance.sh`: flag at `~/.cache/keystone/maintenance.flag`
  (overridable via `KS_MAINT_FLAG`); `ks_maintenance_is_active`,
  `ks_maintenance_skip_if_active`, `ks_maintenance_enter`,
  `ks_maintenance_exit`; SKIP format: `[SKIP] <job>: maintenance window active (flag: <path>)`;
  never prints secret var names
- `ks_maintenance_skip_if_active` wired in 5 wrappers BEFORE `_deploy_env.sh`
  (exits 0 before any curl/ntfy/env loading):
  smoke-cf, smoke-origin, resource-sentinel, db-hygiene, publish-kdat
- `restore-drill-remote.sh`: acquires maintenance lock, calls
  `ks_maintenance_enter` before exec-tee; combined EXIT trap clears both
  flag and `TMP_OUT`
- Timer jitter (`RandomizedDelaySec=75`, `AccuracySec=1min`) added to
  smoke-cf.timer, smoke-origin.timer, resource-sentinel.timer
- Install scripts for those 3 timers run `systemctl --user restart <timer>`
  after enable so jitter takes effect immediately
- `scripts/test_kdat041_maintenance_skip.sh` (isolated HOME, stub curl exits
  99 on invocation, flag at correct path) — **20/20 PASS**: exit 0 + `[SKIP]` +
  flag path + no curl for all 5 wrappers

---

## What this milestone does NOT prove

- Distributed maintenance coordination across multiple hosts
- That db-hygiene.timer and restore-drill-remote.timer receive jitter
  (only 3 timers updated in this milestone)
- Automatic re-enable after maintenance window (operator must call
  `ks_maintenance_exit` or remove the flag manually)

---

## Public-safe claims

"Operators can suppress all five periodic maintenance jobs with a single
`touch ~/.cache/keystone/maintenance.flag`. Each wrapper checks the flag
before any API call and exits 0 with a `[SKIP]` log line. Restore drills
enter the maintenance window automatically and clean up on exit. Timer jitter
prevents simultaneous timer stampedes. 20/20 tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `48dc787` | feat(kdat-041): maintenance window skip + timer jitter |
| Maintenance helper | `scripts/_maintenance.sh` | flag-file based; enter/exit lifecycle |
| Wrappers patched | 5 × `*-with-alert.sh` + `publish-kdat.sh` | skip before env load |
| Restore drill | `scripts/restore-drill-remote.sh` | auto-enter/exit maintenance window |
| Timer units | `smoke-cf.timer`, `smoke-origin.timer`, `resource-sentinel.timer` | RandomizedDelaySec=75 |
| Regression tests | `scripts/test_kdat041_maintenance_skip.sh` | 20/20 PASS |
| Docs | `docs/public-access.md` | "Maintenance window (KDAT-041)" section |

---

## Verification and tests

**`scripts/test_kdat041_maintenance_skip.sh`** — 20/20 PASS

Tests confirm: for each of the 5 wrappers, when maintenance flag is set:
- Script exits 0
- Output contains `[SKIP]`
- Output contains the flag path
- Stub curl is never called (exit 99 trap not triggered)

---

## Known limitations and caveats

- Flag is process-local (file on local disk); no distributed coordination.
- `restore-drill-remote.sh` enters maintenance automatically, which suppresses
  any other job that runs during the drill. This is intentional.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-15.

| Commit | Purpose |
|--------|---------|
| `48dc787` | Delivery: `_maintenance.sh` + 5 wrapper patches + timer jitter |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat041_maintenance_skip.sh
```
