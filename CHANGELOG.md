# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/) and this project adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-10-21

### Security
- Upgrade PHP from RHEL AppStream inside the RHSM-registered layer, picking up
  php 8.3.36 (CVE-2026-109618, CVE-2026-109619) before the UBI repos sync.
- Smoke test fails if php-fpm is older than 8.3.36.

### Changed
- Constitution is now a v1.18.0 manifest: fleet and profile rules apply by
  reference, and only this repo's specifics are kept.
- Constitution validation is pinned via `constitution.yml`.
- Dependabot auto-merges GitHub Actions minor and patch updates.

## [1.0.0] - 2026-09-20

First tagged release. This image has been running in production since before
it had version control; this release marks the current state as the baseline
going forward.
