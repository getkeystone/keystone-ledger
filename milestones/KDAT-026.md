# KDAT-026 — Public Demo Reset Timer

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

A hardened systemd timer runs `public-reset.sh` daily at 04:15 to restore
the public demo to a known-good state; the installer enforces `PUBLIC_DEMO_MODE=1`
and a reset token as prerequisites, preventing accidental installation on
non-demo systems.

---

## What this milestone proves

- `scripts/public-reset.sh`: extended with preflights — refuses to run if
  `PUBLIC_DEMO_MODE != 1` or `PUBLIC_DEMO_RESET_TOKEN` is unset; prevents
  silent failures in production-adjacent environments
- `docs/systemd/public-reset.service`: hardened oneshot systemd user unit
  (`NoNewPrivileges`, `PrivateTmp`, `ProtectSystem=strict`); reads env from
  `~/.config/keystone/env`
- `docs/systemd/public-reset.timer`: daily at 04:15 local time, `Persistent=true`
  (fires on next start if missed)
- `scripts/install-public-reset-timer.sh`: idempotent installer — copies units,
  runs `systemctl --user daemon-reload`, enables and starts timer; refuses
  installation if `PUBLIC_DEMO_MODE != 1` or token unset
- `docs/public-access.md`: "Daily reset timer" section with install/verify
  commands and guard demonstration output
- Guard verified: running installer with `PUBLIC_DEMO_MODE=0` outputs
  `[FAIL] PUBLIC_DEMO_MODE is not enabled (got '0').` and exits non-zero
- Active timer verified: `systemctl --user status public-reset.timer` →
  `active (waiting) Trigger: 04:15:00 ADT; 15h left`

---

## What this milestone does NOT prove

- That the timer fires correctly in all timezone and DST configurations
- That `public-reset.sh` fully resets all state in every possible corpus
  configuration (corpus content is environment-specific)
- Automated CI verification of the timer firing (systemd timers cannot be
  fully exercised in a stateless CI runner)
- Multi-host or coordinated reset for distributed deployments

---

## Public-safe claims

"A systemd user-unit timer runs the demo reset script daily at 04:15.
The installer enforces prerequisites: `PUBLIC_DEMO_MODE=1` and a reset
token must be set. Installation without these conditions is refused with
an explicit error. The timer is hardened with `NoNewPrivileges`,
`PrivateTmp`, and `ProtectSystem=strict`."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Delivery commit | keystone-deploy `3d27116` | test(kdat-026) — 5 files, 217 insertions |
| Verification commit | keystone-deploy `cb8e02d` | test(kdat-026): structural verification script |
| Verification script | `scripts/test_kdat026_timer.sh` | PASS 13 / FAIL 0 / SKIP 0; 11 CI-safe + 2 live assertions |
| Reset script (extended) | `scripts/public-reset.sh` | Preflights: PDM check + token check |
| Systemd service unit | `docs/systemd/public-reset.service` | Hardened oneshot unit |
| Systemd timer unit | `docs/systemd/public-reset.timer` | Daily 04:15, Persistent=true |
| Installer | `scripts/install-public-reset-timer.sh` | Idempotent; refuses if guards fail |
| Docs | `docs/public-access.md` | "Daily reset timer" section |

---

## Verification and tests

**`scripts/test_kdat026_timer.sh`** — 13 assertions (11 CI-safe, 2 live-system); PASS 13 / FAIL 0 / SKIP 0:

| # | Assertion | CI-safe? |
|---|-----------|----------|
| 1 | `systemd-analyze verify docs/systemd/public-reset.service` → clean | Yes |
| 2 | `systemd-analyze verify docs/systemd/public-reset.timer` → clean | Yes |
| 3 | `public-reset.service` contains `NoNewPrivileges=yes` | Yes |
| 4 | `public-reset.service` contains `ProtectSystem=strict` | Yes |
| 5 | `public-reset.service` contains `PrivateTmp=yes` | Yes |
| 6 | `public-reset.timer` contains `OnCalendar=*-*-* 04:15:00` | Yes |
| 7 | `public-reset.timer` contains `Persistent=true` | Yes |
| 8 | `scripts/public-reset.sh` exists and executable | Yes |
| 9 | `scripts/install-public-reset-timer.sh` exists and executable | Yes |
| 10 | Installer guard A: refuses when `PUBLIC_DEMO_MODE` not set (temp HOME, CI-safe) | Yes |
| 11 | Installer guard B: refuses when `PUBLIC_DEMO_RESET_TOKEN` unset (temp HOME, CI-safe) | Yes |
| 12 | `public-reset.timer` is active (live system) | No — skips if no user session |
| 13 | Next trigger confirmed via `list-timers` | No — skips if no user session |

All 11 CI-safe assertions pass without a live systemd user session. Guards are tested
by running the installer against a crafted temp `HOME`, avoiding any live state mutation.

---

## Known limitations and caveats

- The daily timer trigger cannot be fully exercised in a stateless CI environment.
  Structural assertions (unit lint, hardening, schedule, guards, executables) are
  CI-safe via `test_kdat026_timer.sh`. Live timer active and next trigger confirmed
  on the delivery system (assertions 12–13).
- `Persistent=true` means the timer fires on the next system start if it
  missed its window; this is intentional but should be documented for operators
  who restart the host during the 04:15 window.
- Timer runs as a user unit; `loginctl enable-linger` is required for it to
  survive user logout.

---

## Source basis

Two commits on lrfd-backend-bootstrap. Date: 2026-03-14.

| Commit | Purpose |
|--------|---------|
| `3d27116` | Delivery: timer units, installer, guard logic |
| `cb8e02d` | Verification: `test_kdat026_timer.sh` PASS 13/FAIL 0/SKIP 0 |

---

## Fastest verification method

```bash
cd ~/keystone/keystone-deploy

# Full structural + guard verification (CI-safe — assertions 1–11):
bash scripts/test_kdat026_timer.sh
# Expected: PASS 13 / FAIL 0 / SKIP 0

# Live timer status and next trigger:
systemctl --user list-timers public-reset.timer --no-pager

# Journal from last run (if fired):
journalctl --user -u public-reset.service -n 50 --no-pager
```
