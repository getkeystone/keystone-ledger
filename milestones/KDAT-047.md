# KDAT-047 — DB Schema Contract Check for run_id

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/verify-db-schema.sh` is a non-writing contract check that verifies
the six `run_id` schema objects introduced by KDAT-046 (three nullable columns
+ three partial btree indexes) are present on the live database. It fails
explicitly on any missing object so that restore-drills and volume rebuilds
cannot silently miss the migration. The check is wired into
`smoke-origin.sh` as check O-2 (first in the chain, before supply-chain
manifest and HTTP probes).

---

## What this milestone proves

- `scripts/verify-db-schema.sh`: non-writing contract check; verifies all 6
  `run_id` schema objects (3 × nullable column + 3 × partial btree index)
  are present on the live DB
- On FAIL: prints a boxed remediation block with the exact idempotent DDL
  commands needed to fix the database
- `KS_PSQL_CMD` override for deterministic fixture-based testing without
  altering or requiring a specific DB state
- KDAT-041 maintenance skip + KDAT-038 lock: runs safely as a periodic /
  on-demand job
- `smoke-origin.sh O-2`: wired as the first check in the origin smoke chain,
  before supply-chain manifest and HTTP probes; schema regressions surface
  before anything else
- `scripts/test_kdat047_schema_contract.sh` — **13/13 PASS**:
  - Live-DB PASS path (if DB running)
  - `KS_PSQL_CMD` fixture PASS path
  - `KS_PSQL_CMD` fixture FAIL-column path (missing column)
  - `KS_PSQL_CMD` fixture FAIL-index path (missing index)
  - Remediation box present in FAIL output
  - Output hygiene (no secret values)
  - Maintenance skip fires before any psql call
- `docs/public-access.md`: 131 lines of new documentation for this check

---

## What this milestone does NOT prove

- That the `run_id` columns are populated correctly by application code
  (schema presence only — not data integrity)
- End-to-end live-DB path without a running postgres container (live path
  skipped in tests if postgres is not running)
- That KDAT-046 delivery commit has been made (KDAT-046 is in-progress as of
  this milestone; the schema objects may be applied manually or via migration
  if the volume was rebuilt from `16-run-id.sql`)

---

## Public-safe claims

"A non-writing schema contract check verifies that all six `run_id` schema
objects (columns + partial indexes) exist in the live database. It is wired
as the first check in the origin smoke chain (O-2). On failure it prints
exact idempotent DDL remediation commands. 13/13 tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `8bbb03f` | feat(kdat-047): db schema contract check for run_id |
| Schema check | `scripts/verify-db-schema.sh` | non-writing; KS_PSQL_CMD override; remediation box |
| Smoke gate | `scripts/smoke-origin.sh` O-2 | first in chain; FAIL on missing objects |
| Regression tests | `scripts/test_kdat047_schema_contract.sh` | 13/13 PASS |
| Docs | `docs/public-access.md` | 131 lines; check description + remediation commands |

---

## Verification and tests

**`scripts/test_kdat047_schema_contract.sh`** — 13/13 PASS

| Test | Assertion |
|------|-----------|
| Fixture PASS | All 6 objects present → exit 0 |
| Fixture FAIL-column | Missing column → exit 1 + `[FAIL]` |
| Fixture FAIL-index | Missing index → exit 1 + `[FAIL]` |
| Remediation box | FAIL output contains boxed DDL remediation |
| Output hygiene | No secret values in output |
| Maintenance skip | Exits 0 before any psql call when flag set |

---

## Known limitations and caveats

- This check requires KDAT-046 schema objects to exist in the database. If
  KDAT-046 migration has not been applied, O-2 will FAIL on every smoke run
  until the migration is executed.
- `KS_PSQL_CMD` override bypasses live psql; all 13 tests pass in a fixture
  environment; live-DB path requires running postgres.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-16. Unpushed HEAD.

| Commit | Purpose |
|--------|---------|
| `8bbb03f` | Delivery: verify-db-schema.sh + smoke O-2 + 13-test suite |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat047_schema_contract.sh
```
