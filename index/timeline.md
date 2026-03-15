# Timeline

This timeline is derived from commit dates on lrfd-backend-bootstrap
(2026-03-13 through 2026-03-14) and from the position of historical
baseline milestones.

Dates shown are approximate commit dates from the evidence log.
Earlier milestones predate the branch and do not have recorded dates
in this log.

---

## Historical baselines (pre-branch)

These milestones have no commit dates in the current evidence log.
They establish the foundation all subsequent work builds on.

- **KDAT-001A** — Single-machine governed retrieval proof
- **KDAT-002** — Console operator workflow UX

---

## Curated-summary milestones (ordering approximate)

These appear in the curated summary in this order, suggesting approximate
delivery sequence. Branch commits are not directly available for these.

- **KDAT-003** — Document governance UI + APIs *(later confirmed as branch-proven)*
- **KDAT-004** — Signed deterministic evidence bundles
- **KDAT-005** — Approvals workflow
- **KDAT-006** — Operator decision receipt + incident pack
- **KDAT-007** — Supervisor workflow *(doc-only on this branch)*
- **KDAT-008** — Case pack offline verifier *(branch-proven: 2026-03-13)*
- **KDAT-009** — Case timeline UI
- **KDAT-010** — Run it like a product
- **KDAT-011A/B/C** — Demo mode, ProcedureCard, one-command demo run

---

## KDAT-011 grouping note

The delivery table in the evidence log treats KDAT-011 as a single grouped
milestone with commits in keystone-console (`3112590`) and keystone-deploy
(`1f22624`), both dated 2026-03-13. The curated summary subdivides this into:

- **KDAT-011A**: Demo Mode toggle + safe failure UX
- **KDAT-011B**: ProcedureCard presentation
- **KDAT-011C**: One-command demo run (`demo-run.sh`)

This subdivision is a narrative description, not commit-level evidence. The
011A, 011B, 011C pages carry "Curated summary" evidence class. Only 011C has
partial branch evidence (admin-only label gate via check-dist-leaks.sh and
the `a377ff8` / `b026186` console commits).

Do not conflate the grouped KDAT-011 delivery table entry with the sub-milestone
pages as if they were independently proven milestones.

---

## Branch-proven milestones (lrfd-backend-bootstrap, 2026-03-13 to 2026-03-14)

| Date (approx) | Milestone | Summary |
|---------------|-----------|---------|
| 2026-03-13 | KDAT-003 | Document governance APIs + console UI |
| 2026-03-13 | KDAT-008 | Case pack offline verifier |
| 2026-03-13 | KDAT-011 | Demo mode + stack scripts (grouped) |
| 2026-03-13 | KDAT-012 | Structured requirements extraction |
| 2026-03-13 | KDAT-013 | Requirements hygiene + content_kind rerank |
| 2026-03-13 | KDAT-014 | Operator trust polish |
| 2026-03-13 | KDAT-015 | Spec-retrieval generalization |
| 2026-03-13 | KDAT-016 | Metadata sidecar always applies |
| 2026-03-13 | KDAT-017 | Operator trust defaults |
| 2026-03-13 | KDAT-018 | Tighter operator trust defaults |
| 2026-03-13 | KDAT-019 | Domain + content_kind governance |
| 2026-03-13 | KDAT-021 | Orphan sidecar CI gate |
| 2026-03-13/14 | KDAT-020 | Suggested queries panel |
| 2026-03-14 | KDAT-022 | Backup + restore with smoke verification |
| 2026-03-14 | KDAT-023 | Evidence signing key custody + rotation + trust store |
| 2026-03-14 | KDAT-024 | Operational scope guard + CLARIFY_MODEL clarifier |
| 2026-03-14 | KDAT-025 | Cloudflare Access smoke proof |
| 2026-03-14 | KDAT-026 | Public demo reset timer |
| 2026-03-14 | KDAT-027 | KDAT log publisher + external CF smoke timer |
| 2026-03-14 | KDAT-028 | Scheduled DB hygiene |
| 2026-03-14 | KDAT-029 | Resource sentinel timer |
| 2026-03-14 | KDAT-030 | Pinned images + supply chain manifest |
| 2026-03-14 | KDAT-031 | Restore drill + manifest in backups |
| 2026-03-14 | KDAT-032 | Audit export + offline verifier |
| 2026-03-14 | KDAT-034 | Restore enforcement: modern vs. legacy bundle |
| 2026-03-14 | KDAT-035 | Bundle config + trust bootstrap |
| 2026-03-14 | KDAT-036 | Scheduled cross-host restore drill |
| 2026-03-15 | KDAT-037 | Audit verifier: redact env var names |

---

## Evidence log metadata

- Branch: lrfd-backend-bootstrap
- Log generated: 2026-03-14T13:27:36Z (initial); extended 2026-03-14 for KDAT-022–026; extended 2026-03-14 for KDAT-027; extended 2026-03-15 for KDAT-028–037
- keystone-gov HEAD at KDAT-028–037 extension: `c0a9a27`
- keystone-console HEAD at KDAT-028–037 extension: `3e4f589`
- keystone-deploy HEAD at KDAT-028–037 extension: `94e71ec` (includes KDAT-028–037 deliveries)
- Prior HEAD SHAs (KDAT-027 extension): gov `c0a9a27`, console `3e4f589`, deploy `36fe893`
- Prior HEAD SHAs (KDAT-022–026 extension): gov `b4b34c8`, console `b254491`, deploy `3d27116`
- Prior HEAD SHAs (initial log): gov `93aa470`, console `8f7abd5`, deploy `3dbaaa0`
