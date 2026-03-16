# KDAT-038 — Non-Overlap Locks for Scheduled Maintenance Jobs

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/_lock.sh` provides a shared `ks_lock_or_skip()` helper using
`flock -n` with auto-assigned FD. Six periodic job wrappers (smoke-cf,
smoke-origin, db-hygiene, resource-sentinel, publish-kdat,
restore-drill-remote) acquire named locks before any work. If a lock is
already held the job exits 0 with a standardised `[SKIP] <job>: already
running` line sent directly to the journal.

---

## What this milestone proves

- `scripts/_lock.sh`: `ks_lock_or_skip()` uses `flock -n`; lock dir
  `~/.cache/keystone/locks/`; prints `[SKIP] <job>: already running` and
  exits 0 when lock is held
- Six job wrappers now acquire named locks before any work:
  `smoke-cf.lock`, `smoke-origin.lock`, `db-hygiene.lock`,
  `resource-sentinel.lock`, `publish-kdat.lock`, `restore-drill-remote.lock`
- `restore-drill-remote.sh`: lock is acquired before `exec-tee` capture so
  the `[SKIP]` line goes directly to the journal
- `docs/systemd/*.service` (4 hardened units): `ReadWritePaths` updated to
  include `%h/.cache/keystone` for lock dir access under `ProtectHome=read-only`
- `scripts/test_kdat038_locks.sh`: deterministic test — holds each lock in a
  background subshell, asserts each wrapper script exits 0 and prints the
  `[SKIP]` line; 6 jobs tested, completes in < 5 s

---

## What this milestone does NOT prove

- Cluster-level locking across multiple hosts (flock is single-host only)
- Lock behaviour under systemd transient unit restart racing
- That lock timeouts are handled (flock -n exits immediately; no timeout path)

---

## Public-safe claims

"All six scheduled maintenance job wrappers acquire a named flock lock before
executing. If a concurrent invocation finds the lock held, it exits 0 with a
`[SKIP]` log line rather than overlapping. Verified by a deterministic test
holding each lock from a background subshell."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `1fe3bb2` | feat(kdat-038): add non-overlap locks for scheduled maintenance jobs |
| Lock helper | `scripts/_lock.sh` | `ks_lock_or_skip()`; flock -n; `~/.cache/keystone/locks/` |
| Job wrappers patched | `scripts/smoke-cf-with-fix.sh`, `smoke-origin-with-alert.sh`, `db-hygiene-with-alert.sh`, `resource-sentinel-with-alert.sh`, `publish-kdat.sh`, `restore-drill-remote.sh` | Lock before any work |
| Regression tests | `scripts/test_kdat038_locks.sh` | 6 jobs tested |
| Service units | `docs/systemd/*.service` (4 units) | ReadWritePaths added for lock dir |

---

## Verification and tests

**`scripts/test_kdat038_locks.sh`** — 6 jobs tested:

| Job | Lock file | Assert |
|-----|-----------|--------|
| smoke-cf-with-fix.sh | smoke-cf.lock | exit 0 + `[SKIP]` |
| smoke-origin-with-alert.sh | smoke-origin.lock | exit 0 + `[SKIP]` |
| db-hygiene-with-alert.sh | db-hygiene.lock | exit 0 + `[SKIP]` |
| resource-sentinel-with-alert.sh | resource-sentinel.lock | exit 0 + `[SKIP]` |
| publish-kdat.sh | publish-kdat.lock | exit 0 + `[SKIP]` |
| restore-drill-remote.sh | restore-drill-remote.lock | exit 0 + `[SKIP]` |

---

## Known limitations and caveats

- flock is host-local; two machines running the same timer simultaneously
  will not coordinate.
- Lock files accumulate under `~/.cache/keystone/locks/`; no automatic
  cleanup beyond process exit (lock is released when the FD closes).

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-15.

| Commit | Purpose |
|--------|---------|
| `1fe3bb2` | Delivery: `_lock.sh` helper + 6 wrappers + test script |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat038_locks.sh
```
