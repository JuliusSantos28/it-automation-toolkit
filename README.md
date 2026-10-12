# IT Automation Toolkit

A collection of practical, production-inspired scripts and configs I use and share:
PowerShell for identity lifecycle automation, Python for everyday utilities, and
Terraform for repeatable cloud infrastructure.

> These are sanitized, example-grade implementations — no company data, credentials,
> or internal system names. Domains like `corp.example.com` are placeholders.

## Contents

| Folder | What's inside |
|---|---|
| [`powershell/`](powershell) | Active Directory user lifecycle: onboarding, offboarding, access-review reporting |
| [`python/`](python) | Log parsing, bulk file organization, and other day-to-day utilities |
| [`terraform/`](terraform) | Example AWS VPC with public/private subnets — variables, no hardcoded secrets |

## Why this exists

Most IT toil is repetitive: provisioning accounts, deprovisioning leavers, pulling
the same reports, organizing the same files. Each script here automates one of those
jobs end to end — the same approach I take at work, where automation replaced a paid
ticketing system (~$50K/yr saved) and fully automated HR onboarding/offboarding
workflows across departments.

## Usage

Every script is documented at the top with parameters and examples. They are written
to be read and adapted, not just run — tweak the placeholder values (domains, OUs,
paths) for your own environment.

## License

MIT — use freely, attribution appreciated.
