# KDAT-040 — Repo Cleanliness Guard for Destructive Ops

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`scripts/_repo_state.sh` provides `ks_repo_state_guard` — a pre-condition
check that prevents destructive operations (fresh restore, image-digest
upgrade, evidence-key rotation, restore drill) from running against a dirty
working tree. Guard mode is configurable: `fail` exits 1, `warn` logs a
`[WARN]` but continues. `ALLOW_DIRTY_REPOS=1` overrides fail mode with an
explicit acknowledgement warning. The supply-chain manifest generator now
includes `dirty`, `modified_count`, and `untracked_count` per repo.

---

## What this milestone proves

- `scripts/_repo_state.sh`: `_ks_rs_info` collects name, path, branch,
  head SHA, dirty flag, modified count, untracked count for each of 3
  keystone repos — never prints file names; counts only
- `ks_repo_state_guard fail` → exits 1 when any repo is dirty
- `ks_repo_state_guard warn` → exits 0 with `[WARN]` when dirty
- `ALLOW_DIRTY_REPOS=1` overrides fail mode with explicit `[WARN]` acknowledgement
- Guards wired in fail mode: `restore.sh --fresh`, `upgrade-image-digests`,
  `rotate-evidence-keys`, `restore-drill-remote fresh`
- Guards wired in warn mode: `restore.sh clean`, `restore-drill-remote safe`
- `generate-supplychain-manifest.sh` now uses `_ks_rs_info`; repos section
  includes `branch`, `dirty`, `modified_count`, `untracked_count`
  (deterministic via `sort_keys=True`); old `dirty_files` field removed
- `scripts/test_kdat040_repo_state.sh` — **10/10 PASS**:
  - T1: clean repo + warn mode → exit 0, no DIRTY
  - T2: dirty repo + warn mode → exit 0, DIRTY present
  - T3: dirty repo + fail mode → exit 1, `[FAIL]` present
  - T4: dirty repo + fail + `ALLOW_DIRTY_REPOS=1` → exit 0, override warning
  - T5: `ks_repo_state_summary` against real repos → runs without error

---

## What this milestone does NOT prove

- Locking against concurrent write from external processes (only guards
  against pre-existing uncommitted changes)
- That all destructive scripts in the repo are guarded (only the five
  explicitly listed above)
- Multi-repo atomic consistency (each repo checked independently)

---

## Public-safe claims

"Destructive operations (fresh restore, image-digest upgrade, evidence-key
rotation, restore drill) are guarded against running on a dirty working tree.
A `warn` mode allows operator acknowledgement via `ALLOW_DIRTY_REPOS=1`.
The supply-chain manifest now records repo cleanliness state (dirty flag,
modified count, untracked count) per repo. 10/10 tests pass."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `cc01d3f` | feat(kdat-040): repo cleanliness guard for destructive ops |
| Repo state helper | `scripts/_repo_state.sh` | `ks_repo_state_guard`, `ks_repo_state_summary`, `_ks_rs_info` |
| Wired scripts | `restore.sh`, `upgrade-image-digests`, `rotate-evidence-keys`, `restore-drill-remote.sh` | fail/warn modes |
| Manifest | `generate-supplychain-manifest.sh` | richer repos section |
| Regression tests | `scripts/test_kdat040_repo_state.sh` | 10/10 PASS |
| Docs | `docs/backup-restore.md` | Repo Cleanliness Guard section |

---

## Verification and tests

**`scripts/test_kdat040_repo_state.sh`** — 10/10 PASS

| Test | Assertion |
|------|-----------|
| T1 | Clean repo + warn mode → exit 0, no DIRTY output |
| T2 | Dirty repo + warn mode → exit 0, DIRTY in output |
| T3 | Dirty repo + fail mode → exit 1, `[FAIL]` in output |
| T4 | Dirty + fail + `ALLOW_DIRTY_REPOS=1` → exit 0, override warning |
| T5 | `ks_repo_state_summary` against real repos → no error |

---

## Known limitations and caveats

- Guards are pre-flight only; they do not prevent modifications during
  script execution.
- `dirty_files` field removed from manifest; downstream consumers expecting
  that field must be updated.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-15.

| Commit | Purpose |
|--------|---------|
| `cc01d3f` | Delivery: `_repo_state.sh` + guard wiring + manifest update |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy
bash scripts/test_kdat040_repo_state.sh
```
