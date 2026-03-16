# KDAT-046 — Run ID Tagging and Ephemeral Write Purge

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

Adds a nullable `run_id TEXT` column (plus partial btree index) to three
write tables (`operator_decisions`, `incident_cases`,
`incident_case_queries`). `scripts/_run_id.sh` generates deterministic
run IDs (`run-YYYYMMDD-HHMMSSZ-<6hex>`). `scripts/purge-run.sh` deletes all
rows tagged with a given `KS_RUN_ID` behind a double-gate. This allows CF
supervisor-workflow smoke writes to be cleanly purged after a test run.

---

## What this milestone proves

- `initdb/16-run-id.sql`: idempotent (`ADD COLUMN IF NOT EXISTS`,
  `CREATE INDEX IF NOT EXISTS`) — adds `run_id TEXT` + partial btree index
  to `operator_decisions`, `incident_cases`, `incident_case_queries`
- `scripts/_run_id.sh`: `ks_run_id_generate` format `run-YYYYMMDD-HHMMSSZ-<6hex>`;
  `ks_run_id_export` generates, exports `KS_RUN_ID`, and prints the value
- `scripts/purge-run.sh`: double-gate (`KS_RUN_ID` + `PURGE_RUN_ACK=I_ACCEPT_DELETE`);
  validates run_id charset and max length 80; purge order: queries → cases →
  decisions; exits 1 on guard failure, 2 when postgres unreachable
- `scripts/supervisor-flow-cf.sh` patched: forwards `KS_RUN_ID` as
  `X-Keystone-Run-Id` header on every POST/PATCH API call, tagging all rows
  written by a single workflow run
- `scripts/test_kdat046_run_id_purge.sh` — **15/15 PASS**: ID generation,
  charset validation, export subshell fix, purge gate enforcement, purge
  happy-path with fake psql, invalid-run-id guard

---

## What this milestone does NOT prove

- End-to-end live-DB purge without a running postgres container (DB path
  tests skip when postgres is not running)
- That every write path in the application uses run_id tagging (only
  supervisor-flow-cf.sh is patched in this milestone)
- Automatic scheduled purge (operator must invoke purge-run.sh)

---

## Public-safe claims

"Every row written by a CF supervisor workflow smoke run is tagged with a
unique `run_id`. A guarded purge script (`purge-run.sh`) cleans up tagged
rows behind a double-gate (run ID + explicit ACK). The DB schema migration is
idempotent. 15/15 contract tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `016900d` | feat(kdat-046): ephemeral CF workflow writes with run_id tagging + purge |
| SQL migration | `initdb/16-run-id.sql` | idempotent; 3 columns + 3 indexes |
| Run ID generator | `scripts/_run_id.sh` | `ks_run_id_generate`, `ks_run_id_export` |
| Purge script | `scripts/purge-run.sh` | double-gate; purge order: queries→cases→decisions |
| Supervisor patch | `scripts/supervisor-flow-cf.sh` | X-Keystone-Run-Id header on all writes |
| Regression tests | `scripts/test_kdat046_run_id_purge.sh` | 15/15 PASS |

---

## Verification and tests

**`scripts/test_kdat046_run_id_purge.sh`** — 15/15 PASS

Tests cover: ID format correctness, uniqueness, export, charset validation,
max-length guard, all purge gate combinations, happy-path with fake psql,
idempotency, postgres-unreachable exit 2.

---

## Known limitations and caveats

- DB tests skip when postgres container is not running.
- run_id columns are nullable — rows written without a run_id cannot be
  targeted by purge-run.sh.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16.

| Commit | Purpose |
|--------|---------|
| `016900d` | Delivery: SQL migration + _run_id.sh + purge-run.sh + supervisor patch |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat046_run_id_purge.sh
```
