# Security Policy

## Scope

This repository contains published milestone documentation and the small set
of publication-gate scripts under `scripts/` that enforce it (the claims-matrix
verifier, the retired-claim sanitizer, and the pre-push hook that runs them). It
does not contain production credentials, infrastructure configurations,
deployment or operational scripts, or internal-only tooling.

## Reporting a security concern

If you believe a file in this repository inadvertently exposes sensitive
information (hostnames, credentials, personal data, internal infrastructure
details), open a private security advisory via GitHub or contact the
maintainers directly.

Do not open a public issue for potential information exposure. Use the
private advisory channel.

## What this repository does not contain

- API keys or secrets
- Private hostnames or internal URLs
- Personal information
- Raw internal operational notes
- Internal-only operational, deployment, or ops tooling

All content in this repository has passed publication safety review as
described in [docs/publication-policy.md](docs/publication-policy.md).
