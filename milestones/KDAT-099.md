# KDAT-099 — Review Workflow Separation of Duties

**Status:** Proven
**Evidence class:** Proven on current branch
**Publication status:** Ready to publish

---

## Summary

Feedback submitter cannot resolve their own review task. Enforced at the API layer with a 403 response and descriptive message. This ensures the person who flagged a knowledge gap is not the same person who declares it resolved.

---

## What this milestone proves

- `POST /review/tasks/{id}/resolve`: compares `task.feedback_submitter` with requesting user identity
- 403 response with message "Separation of duties: feedback submitter cannot resolve their own task"
- Separation of duties applies to `resolve` endpoint; `dismiss` and `comment` do not require this check
- Enforcement uses the server-derived identity (CF Access or session token), not a client-supplied role claim

---

## Public-safe claims

"Review workflow separation of duties: feedback submitter cannot resolve their own review task. Enforced at API layer, returns 403 with descriptive message."

---

## Evidence and artifacts

| Item | Location | Notes |
|------|----------|-------|
| API endpoint | `keystone-gov` `323dba4` | POST /review/tasks/{id}/resolve with SoD check |
| Error message | Inline in resolve handler | "Separation of duties: feedback submitter cannot resolve their own task" |

---

## Source basis

Date: 2026-03-29

| Commit | Repo | Purpose |
|--------|------|---------|
| `323dba4` | keystone-gov | feat: review workflow — SoD enforcement on resolve |
