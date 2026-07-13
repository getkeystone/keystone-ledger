# KDAT-036 — Scheduled Cross-Host Restore Drill

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

A weekly systemd user-unit timer runs an automated restore drill every Sunday
at 03:55 local time. The drill restores the most recent backup bundle, runs
`smoke-origin.sh`, and exports an audit bundle for verification. It operates
in two modes: local (host-primary only) or remote (restore on host-restore via SSH).
An ntfy alert is sent on any FAIL.

---

## What this milestone proves

- `scripts/restore-drill-remote.sh` (new, 370 lines):
  - **Local mode** (when `RESTORE_HOST` is not set): restores bundle on
    host-primary; runs `smoke-origin.sh`; exports audit
  - **Remote mode** (when `RESTORE_HOST` is set): copies bundle to host-restore
    via scp; runs restore + smoke + audit export on host-restore via SSH
  - `RESTORE_DRILL_MODE=safe` (default): clean reload — no volume wipe; api/web
    briefly restarted
  - `RESTORE_DRILL_MODE=fresh`: full wipe; requires `RESTORE_DRILL_ACK=WIPE_OK`
  - Safety guard: aborts if `CLOUDFLARE_ACCESS_ENABLED=true` and
    `PUBLIC_DEMO_MODE=1` simultaneously (gated pilot must not run with demo mode)
  - ntfy alert with PASS/FAIL summary on exit
- `docs/systemd/restore-drill-remote.service`: oneshot unit; `NoNewPrivileges`,
  `PrivateTmp`; 900-second timeout (generous for restore + smoke + audit);
  reads env from `~/.config/keystone/env`
- `docs/systemd/restore-drill-remote.timer`: `OnCalendar=Sun *-*-* 03:55:00`,
  `Persistent=true`; scheduled after `db-hygiene.timer` (03:30) to minimize
  pilot disruption
- `scripts/install-restore-drill-timer.sh` (new, 150 lines): idempotent;
  checks SSH connectivity to host-restore if `RESTORE_HOST` is set and prints
  remediation steps on failure; copies units; daemon-reload; enables timer;
  prints next trigger
- `docs/backup-restore.md`: "Cross-host Restore Drill (KDAT-036)" section
  with mode table, prerequisites, safety guardrails, setup steps, manual run

---

## What this milestone does NOT prove

- That the timer fires correctly in all timezone and DST configurations
- Automated CI verification of the timer firing (systemd timers cannot be
  fully exercised in a stateless CI runner)
- That host-restore restore succeeds in all network conditions (remote mode
  requires SSH connectivity and pre-configured key)
- Multi-host fleet drills or aggregated pass/fail reporting

---

## Public-safe claims

"A weekly systemd user-unit timer runs an automated restore drill every Sunday
at 03:55 local time. The drill restores the most recent backup bundle and runs
the full smoke suite. It operates in local mode (host-primary only) or remote
mode (restore on host-restore via SSH). Safety guardrails prevent fresh-mode
execution without explicit acknowledgement (`RESTORE_DRILL_ACK=WIPE_OK`)."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `08edbfd` | feat(kdat-036): scheduled cross-host restore drill |
| Drill script | `scripts/restore-drill-remote.sh` | Local + remote modes; 370 lines |
| Systemd service | `docs/systemd/restore-drill-remote.service` | Hardened oneshot; 900-s timeout |
| Systemd timer | `docs/systemd/restore-drill-remote.timer` | Weekly Sunday 03:55, Persistent=true |
| Installer | `scripts/install-restore-drill-timer.sh` | Idempotent; SSH connectivity check |
| Docs | `docs/backup-restore.md` | "Cross-host Restore Drill" section |

---

## Verification

Delivery commit is tagged `feat(kdat-036)`. `systemd-analyze verify` clean
confirmed in prior commits for analogous units. No dedicated structural
verification script on par with `test_kdat026_timer.sh` or
`test_kdat027_timer.sh` exists yet for this timer.

**Publication note:** The delivery commit is direct and appropriately tagged.
The timer structure follows the same pattern as KDAT-026 and KDAT-027 (which
both graduated to Ready to publish). A structural verification script would
strengthen this further but is not required to establish the proven status.

---

## Known limitations and caveats

- Remote mode requires a general-purpose SSH key on host-restore (separate from
  the rsync-only corpus-sync key). Setup is documented in `docs/backup-restore.md`.
- `fresh` mode wipes the postgres data volume; the `RESTORE_DRILL_ACK=WIPE_OK`
  guard must be set explicitly.
- Timer cannot be fully exercised in a stateless CI environment.
- `loginctl enable-linger` is required for the timer to survive user logout.

---

## Source basis

One commit on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `08edbfd` | Delivery: drill script, systemd units, installer, docs |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Manual local drill (safe mode):
RESTORE_DRILL_MODE=safe bash scripts/restore-drill-remote.sh

# Timer status:
systemctl --user list-timers restore-drill-remote.timer --no-pager

# Recent journal:
journalctl --user -u restore-drill-remote.service -n 50 --no-pager
```
