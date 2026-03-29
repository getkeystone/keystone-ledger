# KDAT-098 — Review Workflow Schema and API (Migration 24)

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

`review_tasks`, `review_comments`, and `publication_decisions` tables added via idempotent migration 24. Seven API endpoints for the full review lifecycle. `not_helpful` feedback signals automatically create a review task. The feedback submission endpoint returns `review_task_id` so the caller can track the associated review.

---

## What this milestone proves

- `review_tasks` table: status state machine (`open → assigned → in_review → resolved/dismissed`), priority levels, resolution types, FK to `feedback_signals`
- `review_comments` and `publication_decisions`: append-only; UPDATE/DELETE/TRUNCATE revoked from `keystone_app`
- 7 API endpoints: `GET /review/tasks`, `GET /review/tasks/{id}`, `POST /review/tasks/{id}/assign`, `POST /review/tasks/{id}/comment`, `POST /review/tasks/{id}/resolve`, `POST /review/tasks/{id}/dismiss`, `GET /audit/chain/{feedback_signal_id}`
- Feedback endpoint auto-creates review task for `not_helpful` signals (graceful degradation: try/except so migration 24 not required)
- Feedback response includes `review_task_id` field
- Migration is idempotent

---

## Public-safe claims

"Review workflow schema and 7 API endpoints: task list, detail, assign, comment, resolve, dismiss, audit chain. Not-helpful feedback automatically creates review task. Append-only comments and publication decisions. Migration idempotent."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| Migration | `keystone-demo/initdb/24-review-workflow.sql` | Idempotent; append-only grants |
| API endpoints | `keystone-gov` `323dba4` | 7 endpoints for review lifecycle |
| Auto-task creation | `keystone-gov/api/main.py` | Feedback handler creates task for not_helpful |
| Models | `keystone-gov/api/models.py` | ReviewTask, ReviewComment, PublicationDecision |

---

## Source basis

Date: 2026-03-29

| Commit | Repo | Purpose |
|--------|------|---------|
| `323dba4` | keystone-gov | feat: review workflow (7 endpoints + feedback auto-task) |
| `9231361` | keystone-demo | feat: migration 24 — review_tasks + comments + publication_decisions |
