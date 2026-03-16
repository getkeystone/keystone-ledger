# KDAT-046 — Run ID Tagging and Ephemeral Write Purge

**Status:** In progress
**Evidence class:** Underdocumented
**Publication status:** Needs review

---

## Summary

KDAT-046 adds a `run_id` column to three write tables
(`operator_decisions`, `incident_cases`, `incident_case_queries`) and
corresponding partial btree indexes, plus a `purge-run.sh` script that
deletes all rows tagged with a given `KS_RUN_ID`. This allows smoke writes
to be cleanly purged after a test run. The SQL migration (`initdb/16-run-id.sql`)
and the `_run_id.sh` generator helper exist in the working tree with a
12-test contract suite, but have not yet been committed.

---

## What this milestone proves

- `scripts/_run_id.sh`: `ks_run_id_generate` produces `run-YYYYMMDD-HHMMSSZ-<6hex>`;
  `ks_run_id_export` generates, exports `KS_RUN_ID`, and prints the value
- `initdb/16-run-id.sql`: idempotent (IF NOT EXISTS) — adds `run_id TEXT`
  column to `operator_decisions`, `incident_cases`, `incident_case_queries`;
  adds 3 partial btree indexes on `run_id WHERE run_id IS NOT NULL`
- `scripts/purge-run.sh`: requires `KS_RUN_ID` and explicit
  `KS_PURGE_ACK=I_ACCEPT_PURGE`; validates run_id format and max length 80;
  exits 1 without both guards; exits 2 when postgres unreachable
- `scripts/test_kdat046_run_id_purge.sh` (12 tests):
  - T1–T3: `_run_id.sh` format, uniqueness, export
  - T4–T8: `purge-run.sh` guard checks (no run_id, no ACK, wrong ACK,
    invalid chars, length > 80)
  - T9–T11: DB tests — purge deletes tagged rows, is idempotent (skipped if
    postgres not running)
  - T12: postgres unreachable → exit 2

---

## What this milestone does NOT prove

- Committed delivery: all files are working-tree-only as of 2026-03-16;
  no `feat(kdat-046)` commit exists in git history
- End-to-end live-DB coverage without a running postgres container (T9–T11
  skip when postgres is not available)
- That `purge-run.sh` is idempotent in all edge cases (T11 covers the
  zero-rows case)

---

## Evidence quality note

All four KDAT-046 files (`_run_id.sh`, `initdb/16-run-id.sql`, `purge-run.sh`,
`test_kdat046_run_id_purge.sh`) exist in the working tree on branch
`lrfd-backend-bootstrap` but are uncommitted. KDAT-047 (`8bbb03f`) explicitly
references "six run_id schema objects introduced by KDAT-046", confirming the
milestone is a real in-progress deliverable. This page will be updated to
**Proven / Ready to publish** once the delivery commit is made.

---

## Public-safe claims

Not yet publishable. The capability is in-progress. Do not cite this milestone
in external materials until the delivery commit is made and the test suite runs
to completion.

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | **PENDING** | Not yet committed |
| Run ID generator | `scripts/_run_id.sh` | Working tree; uncommitted |
| SQL migration | `initdb/16-run-id.sql` | Working tree; uncommitted; idempotent |
| Purge script | `scripts/purge-run.sh` | Working tree; uncommitted |
| Test suite | `scripts/test_kdat046_run_id_purge.sh` | 12 tests; working tree; uncommitted |
| KDAT-047 reference | keystone-deploy `8bbb03f` | "six run_id schema objects introduced by KDAT-046" |
| Docs | `docs/public-access.md` | "Ephemeral CF workflow writes (KDAT-046)" section (in KDAT-047 commit) |

---

## Known limitations and caveats

- Milestone cannot be promoted to Ready to publish until the delivery commit
  is made.
- T9–T11 (DB path) require a running postgres container and are skipped in
  most CI environments.

---

## Source basis

Working tree on lrfd-backend-bootstrap. Date: 2026-03-16. No delivery commit.

---

## Next action

Make the `feat(kdat-046)` delivery commit with: `_run_id.sh`, `initdb/16-run-id.sql`,
`purge-run.sh`, `test_kdat046_run_id_purge.sh`. Then update this page to
Proven / Ready to publish.
