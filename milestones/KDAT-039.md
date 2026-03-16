# KDAT-039 — Standardise Timer Env Loading + Preflight + Verify Harness

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/_env_preflight.sh` is a shared helper that locates the env file
(deploy `.env` symlink or `~/.config/keystone/env`), enforces `chmod 600`
on the canonical path, guards against `/.env` when `DEPLOY_DIR="/"`, and
exposes `ks_env_bool` / `ks_require_vars` / `ks_print_env_status` helpers.
All six periodic job wrappers now source it after the lock check and before
any API/curl/ntfy invocation. A verify harness
(`scripts/verify-systemd-jobs.sh`) runs `systemd-analyze verify` across 10
units and confirms env-standardisation in all 5 service files: 22/22 PASS.

---

## What this milestone proves

- `scripts/_env_preflight.sh`: locates env file; enforces chmod 600;
  guards `/.env` when `DEPLOY_DIR="/"` sets `KS_ENV_FILE` to empty;
  provides `ks_env_bool`, `ks_require_vars`, `ks_print_env_status`
- All 6 job wrappers source `_env_preflight.sh` after lock, before
  exec-tee: smoke-cf, smoke-origin, db-hygiene, resource-sentinel,
  publish-kdat, restore-drill-remote
- All 5 service files add `EnvironmentFile=-%h/.config/keystone/env.local`
  (optional host-specific override; leading `-` = no-fail if absent)
- All 5 installer scripts updated with `env.local` setup note
- `scripts/verify-systemd-jobs.sh`: `systemd-analyze verify` (10 units) +
  EnvironmentFile standardisation check (5 services × 2 lines) + runs
  `test_kdat038_locks.sh` and `test_kdat039_env.sh` — **22/22 PASS**
- `scripts/test_kdat039_env.sh` (10 tests):
  - T1: 644 perms → `[FAIL]` + non-zero exit
  - T2: 600 perms → `[OK]` + exit 0 + reached end
  - T3: `DEPLOY_DIR=/` → `KS_ENV_FILE` empty (/.env guard fires)
  - T4: `publish-kdat.sh` output → no forbidden secret strings

---

## What this milestone does NOT prove

- That the env file itself contains all required variables for a given job
  (`ks_require_vars` is available but must be called by each wrapper)
- Runtime secret rotation (env file is read once at job start)
- That `env.local` overrides are tested in isolation

---

## Public-safe claims

"All periodic maintenance job wrappers share a single env-loading helper
that enforces `chmod 600`, guards against dangerous root-dir env paths,
and provides standardised variable access. A verify harness confirms all
systemd units parse cleanly and the env standardisation is in place:
22/22 PASS."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `4a3c310` | feat(kdat-039): standardize timer env + preflight + verify harness |
| Env helper | `scripts/_env_preflight.sh` | chmod 600 guard, /.env guard, helpers |
| Verify harness | `scripts/verify-systemd-jobs.sh` | systemd-analyze + env check + sub-tests |
| Regression tests | `scripts/test_kdat039_env.sh` | 10 tests; isolated DEPLOY_DIR |
| Service files | 5 × `docs/systemd/*.service` | `EnvironmentFile=-%h/.config/keystone/env.local` added |

---

## Verification and tests

**`scripts/test_kdat039_env.sh`** — 10 assertions; **`verify-systemd-jobs.sh`** total: 22/22 PASS

| Test | Assertion |
|------|-----------|
| T1 | 644 perms → `[FAIL]` + non-zero exit |
| T2 | 600 perms → `[OK]` + exit 0 |
| T3 | `DEPLOY_DIR=/` → KS_ENV_FILE empty |
| T4 | `publish-kdat.sh` output → no forbidden secret patterns |

---

## Known limitations and caveats

- `chmod 600` check is advisory; the script warns but does not prevent
  job execution if the operator explicitly sets a different permission.
- `env.local` is optional; absence is silent (leading `-` in service file).

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-15.

| Commit | Purpose |
|--------|---------|
| `4a3c310` | Delivery: `_env_preflight.sh` + verify harness + test script |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/verify-systemd-jobs.sh
```
