# KDAT-028 — Scheduled DB Hygiene

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

An automated PostgreSQL hygiene job runs daily at 03:30 UTC via a hardened
systemd user-unit timer. It prunes old rows from seven operational tables,
runs VACUUM ANALYZE on affected tables, and reports database size. An alert
wrapper sends an ntfy notification on any non-zero exit.

---

## What this milestone proves

- `scripts/db-hygiene.sh`: prunes rows older than `DB_RETENTION_DAYS` (default 30)
  from `operator_decisions`, `incident_cases`, `evidence_export_requests`,
  `corpus_doc_change_requests`, `corpus_doc_events`, `queries`, `audit_log`;
  verifies table and column existence before each DELETE; handles varchar/timestamptz
  cast for `audit_log`; runs VACUUM ANALYZE on tables with actual deletions;
  reports `pg_database_size` and top-10 table sizes; exits 0=PASS / 1=FAIL / 2=WARN
- `scripts/db-hygiene-with-alert.sh`: wraps the hygiene script; captures last
  120 lines of output; sends ntfy alert on exit ≠ 0 if `NTFY_TOPIC` is set;
  never prints secrets
- `docs/systemd/db-hygiene.service`: hardened oneshot user unit (`NoNewPrivileges`,
  `PrivateTmp`, `ProtectSystem=strict`); reads env from `EnvironmentFile`
- `docs/systemd/db-hygiene.timer`: `OnCalendar=*-*-* 03:30:00`, `Persistent=true`
- `scripts/install-db-hygiene-timer.sh`: idempotent installer; validates scripts;
  copies units, daemon-reload, enables and starts timer
- `docs/backup-restore.md`: "DB Hygiene (KDAT-028)" section with pruned-table
  table, tuning variables, manual run and log commands, exit codes

Delivery commit message states: "Verified: PASS 8/8 direct + systemd;
systemd-analyze verify clean; journal shows structured PASS/FAIL banners,
no credentials in output."

---

## What this milestone does NOT prove

- That retention pruning is the correct policy for compliance or audit purposes
  (retention duration is configurable and must be set per deployment)
- Automated CI verification of the timer firing (systemd timers cannot be
  fully exercised in a stateless CI runner)
- Multi-host or sharded database hygiene
- Vacuum efficiency guarantees under high-volume production load

---

## Public-safe claims

"An automated PostgreSQL hygiene job runs daily at 03:30 UTC via a systemd
user-unit timer. It prunes rows from seven operational tables based on a
configurable retention window (default 30 days), runs VACUUM ANALYZE, and
reports database size. A wrapper sends an ntfy alert on non-zero exit.
No credentials appear in log output."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `9bb4e2a` | feat(ops): scheduled db hygiene prune + vacuum + alert |
| Hygiene script | `scripts/db-hygiene.sh` | Prunes 7 tables; VACUUM ANALYZE; size report |
| Alert wrapper | `scripts/db-hygiene-with-alert.sh` | ntfy on non-zero exit; no secret leakage |
| Systemd service | `docs/systemd/db-hygiene.service` | Hardened oneshot unit |
| Systemd timer | `docs/systemd/db-hygiene.timer` | Daily 03:30 UTC, Persistent=true |
| Installer | `scripts/install-db-hygiene-timer.sh` | Idempotent |
| Docs | `docs/backup-restore.md` | "DB Hygiene (KDAT-028)" section |

---

## Verification

Delivery commit states PASS 8/8 (direct + systemd); `systemd-analyze verify`
clean; journal confirmed structured PASS/FAIL output with no credential leakage.

No dedicated structural verification script on par with `test_kdat026_timer.sh`
or `test_kdat027_timer.sh` exists yet. The 8-assertion count is from inline
verification at delivery time, not a committed test script.

**Publication note:** Proven on current branch. The absence of a committed
test script is noted; core functionality is verified by delivery commit
evidence. Publication is appropriate with this caveat stated.

---

## Known limitations and caveats

- No committed regression test script (unlike KDAT-026 and KDAT-027). Inline
  delivery verification (PASS 8/8) is the primary evidence.
- Timer cannot be fully exercised in a stateless CI environment.
- `DB_RETENTION_DAYS` default of 30 days should be reviewed per deployment
  before enabling in any environment with audit retention requirements.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `9bb4e2a` | Delivery: hygiene script, alert wrapper, systemd units, installer, docs |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Manual run (against live stack):
bash scripts/db-hygiene.sh

# Timer status:
systemctl --user list-timers db-hygiene.timer --no-pager

# Recent journal:
journalctl --user -u db-hygiene.service -n 50 --no-pager
```
