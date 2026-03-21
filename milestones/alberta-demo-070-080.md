# Alberta Demo KDATs (070-080)

## KDAT-070: Config-Driven Deployment Architecture
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next
Commits: e11b4ee (keystone-gov), e00643d (keystone-deploy)

What this proves:
- Deployment branding, roles, modes, and suggested queries
  are loaded from a YAML config file at startup
- /api/config endpoint serves deployment config without auth
- /health includes deployment_id
- Switching deployments requires changing one volume mount
- Falls back to sensible defaults if no config file exists

What this does NOT prove:
- Config-driven permissions (role permission sets are still
  hardcoded in code)
- Config-driven LLM prompts
- Config-driven synonyms or policy gates
- Hot-reload of config without container restart

Public-safe claims:
- "Config-driven deployment: switch between customers by
  changing one file"
- "Same engine serves fire departments and industrial
  facilities"

Verification:
  curl -sf http://localhost:8002/config | jq .deployment.name
  # Returns: "Safety Procedure Assistant"


## KDAT-071: Generic Procedural Reranker
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next
Commits: fbc75eb (keystone-gov)

What this proves:
- 90-line generic reranker replaces 800-line LRFD-specific
  reranker
- Four quality filters: TOC/boilerplate, length normalization,
  query term overlap, chunk quality
- No domain-specific logic in the reranker
- LRFD fire-service intent detection removed from call path

What this does NOT prove:
- Reranker quality is optimal (no A/B testing against old reranker)
- Reranker works for non-safety domains
- Reranker tuning is done (weights are initial estimates)

Public-safe claims:
- "Domain-agnostic retrieval quality filtering"
- "No hardcoded domain logic in the ranking pipeline"


## KDAT-072: Alberta OHS Corpus Ingestion
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next

What this proves:
- 57 Alberta OHS documents ingested from public government
  sources
- 2,717 chunks created, all embedded (nomic-embed-text, 768-dim)
- Embedding completed in 79 seconds on RTX 3090
- Human-readable document titles set for all documents
- Domain labels: ohs_regulation (54), industry_reference (3)
- Document metadata: effective_date, review_date, owner,
  content_kind set for all documents

What this does NOT prove:
- Retrieval quality for all 57 documents (eval covers 20 queries)
- PDF table extraction quality (H2S OEL required text supplement)
- Metadata survives re-ingest without sidecars (title preservation
  fix applied but sidecars not yet created)

Sources:
- Alberta Government (open.alberta.ca) under Open Government Licence
- Suncor Energy (publicly posted contractor standard)
- University of Calgary (public code of practice)
- Saga Training Corp (publicly posted training manual)

Public-safe claims:
- "57 Alberta OHS documents indexed and searchable"
- "Real regulatory content, not synthetic test data"


## KDAT-073: Public Demo Deployment
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next

What this proves:
- demo.getkeystone.ai serves the Safety Procedure Assistant
- Cloudflare tunnel (ka-demo) routes to host-primary port 8082
- Separate Docker stack from LRFD production (different
  containers, database, corpus, Caddy config)
- LRFD production stack runs untouched alongside
- Accessible from mobile (phone on cellular data)
- TLS termination via Cloudflare

What this does NOT prove:
- Uptime or availability SLA
- Performance under concurrent load
- Geographic latency for non-North American users

Public-safe claims:
- "Live demo at demo.getkeystone.ai"
- "Runs alongside production pilot without interference"


## KDAT-074: Professional UI Theme
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next

What this proves:
- Light professional theme suitable for industrial safety
- Keystone logo in header and favicon
- Safety-standard accent colors (ANSI red/amber/green)
- Role labels mapped from config (Operator, Supervisor,
  Safety Coordinator, EHS Manager)
- Alberta demo users displayed on login page
- Footer links to getkeystone.ai
- Mobile responsive (tested on phone)

What this does NOT prove:
- WCAG accessibility compliance
- Cross-browser testing beyond Chrome
- Print stylesheet

Public-safe claims:
- "Professional operator-facing console"
- "Role-aware interface with safety-standard visual language"


## KDAT-075: Security Hardening Pass 1
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next
Commits: 7b7e70a (keystone-gov)

What this proves:
- Session expiration (8-hour TTL)
- Login rate limiting (5 attempts/minute per IP)
- Query rate limiting (20 queries/minute per session)
- Query length limit (2000 characters)
- 5xx error response sanitization (no stack traces leaked)
- Security headers on all responses (X-Content-Type-Options,
  X-Frame-Options, Referrer-Policy, Cache-Control)
- 13-finding security audit documented

What this does NOT prove:
- Penetration testing by a third party
- OWASP Top 10 full coverage
- Production-grade session management (no session store,
  in-memory only)
- Rate limiting survives API restart (in-memory counters)

Public-safe claims:
- "Security-hardened API with session management and rate limiting"
- "13-finding security audit with 7 critical/high items resolved"


## KDAT-076: Prompt Injection Mitigation
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next

What this proves:
- 21 regex patterns detect instruction-override attempts
- Output validation catches 8 injection signal phrases
- 10/10 adversarial test queries blocked or contained
- Legitimate queries still return normal results
- Injection attempts logged in audit trail

What this does NOT prove:
- Protection against novel injection techniques
- Protection against indirect injection (via document content)
- Third-party red team validation
- Complete coverage of all possible injection vectors

Public-safe claims:
- "Prompt injection mitigation with input sanitization and
  output validation"
- "Adversarial testing: 10/10 injection attempts blocked"


## KDAT-077: Retrieval Quality Eval Harness
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next
Commits: abf6569 (keystone-gov)

What this proves:
- 20-query eval suite covering 6 demo scenarios, fail-closed,
  injection blocking, and 8 additional OHS topics
- Baseline score: 19/20 (95%)
- Average latency: 1,632ms
- Automated pass/fail with JSON evidence output
- 1 known failure (FIRE-001: hot work content gap, not a
  code bug)

What this does NOT prove:
- Retrieval quality for queries outside the eval suite
- Quality stability over time (no regression tracking yet)
- Statistical significance (20 queries is a smoke test,
  not a benchmark)

Public-safe claims:
- "Retrieval quality: 95% on 20-query eval suite"
- "Automated quality gate with evidence artifacts"


## KDAT-078: Hybrid Weight Optimization
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next
Commits: 3a3c0ca (keystone-gov)

What this proves:
- When FTS AND returns 0 results, hybrid merge flips weights
  to vector 0.70 / FTS 0.30
- This prevents noisy FTS OR-expansion results from drowning
  correct vector search results
- Lockout/tagout query now returns Part 15 (previously missed)
- Default weights (FTS 0.60 / vector 0.40) preserved for
  clean keyword matches

What this does NOT prove:
- Optimal weight values (no systematic tuning)
- Performance impact of the weight flip
- Behavior on non-safety corpora

Public-safe claims:
- "Adaptive hybrid retrieval: keyword and semantic search
  weighted by match quality"


## KDAT-079: Backup and Restore
Status: PROVEN (script exists, no restore drill)
Evidence class: Proven on current branch (partial)
Branch: dev/keystone-next

What this proves:
- backup-dev.sh creates timestamped tar.gz with database
  dump, corpus files, and deployment config
- restore-dev.sh restores from backup with verification

What this does NOT prove:
- Successful restore from a real backup (no drill run)
- Backup integrity verification
- Automated backup scheduling
- Off-site backup storage

Public-safe claims:
- "Backup and restore scripts for database and corpus"
- DO NOT claim "tested backup/restore" until a restore
  drill is run


## KDAT-080: Ingest Metadata Preservation
Status: PROVEN
Evidence class: Proven on current branch
Branch: dev/keystone-next
Commits: 696c714 (keystone-gov)

What this proves:
- Re-running corpus ingest no longer overwrites manually-set
  title, domain, or content_kind
- Only overwrites if current value is NULL, empty, or a known
  auto-derived default
- Sidecar files remain authoritative (override even manual values)

What this does NOT prove:
- Owner, effective_date, review_date preservation (these still
  clear on re-ingest without sidecars)
- Sidecar-based metadata workflow is documented or tested

Public-safe claims:
- "Document metadata preserved across re-ingestion"
