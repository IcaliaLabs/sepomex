# Security Policy

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Report vulnerabilities privately via GitHub's
[Security Advisories](https://github.com/IcaliaLabs/sepomex/security/advisories/new),
or by email to **hola@icalialabs.com**. We'll acknowledge your report as
quickly as we can and keep you updated on the fix.

## Supported versions

The `main` branch (and the latest tagged release) receive security fixes.

## Scope notes

Sepomex is a **read-only, public** API over public postal-code data. It stores
no user data and performs no writes at runtime, so the attack surface is small.
Automated checks run on every pull request:

- **Brakeman** — static application security analysis
- **bundler-audit** — known-vulnerable gem dependencies

## Secrets

Production requires a `SECRET_KEY_BASE` (or `RAILS_MASTER_KEY`) provided via the
environment — never commit it. `config/master.key` is intentionally **not**
tracked in version control.
