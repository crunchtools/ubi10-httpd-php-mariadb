# ubi10-httpd-php-mariadb Constitution

> **Version:** 1.0.0
> **Ratified:** 2026-03-10
> **Status:** Active
> **Inherits:** [crunchtools/constitution](https://github.com/crunchtools/constitution) v1.0.0
> **Profile:** Container Image

UBI 10 PHP + MariaDB leaf image. Inherits Apache httpd, PHP 8.3, php-fpm, and all PHP extensions from ubi10-httpd-php. Adds MariaDB server for WordPress hosting. Requires RHSM for mariadb-server package.

---

## License

AGPL-3.0-or-later

## Versioning

Follow Semantic Versioning 2.0.0. MAJOR/MINOR/PATCH.

## Base Image

`quay.io/crunchtools/ubi10-httpd-php:latest` — inherits httpd, PHP 8.3 with extensions, php-fpm, troubleshooting tools, and systemd hardening.

## Registry

Published to `quay.io/crunchtools/ubi10-httpd-php-mariadb`.

## RHSM Registration

Required. `mariadb-server` is not available in UBI repos. Uses `--mount=type=secret` for subscription-manager registration. Register, install, and unregister happen in a single `RUN` layer so secrets are never cached in intermediate layers.

## Containerfile Conventions

- Uses `Containerfile` (not Dockerfile)
- Required LABELs: `maintainer`, `description`
- `dnf install -y` followed by `dnf clean all`
- `subscription-manager unregister` after package installation
- systemd services enabled: mariadb
- Inherits from parent chain: httpd, php-fpm (enabled), systemd-remount-fs/systemd-update-done/systemd-udev-trigger (masked)
- Inherits `STOPSIGNAL SIGRTMIN+3` and `ENTRYPOINT ["/sbin/init"]` from ubi10-core

## Packages Installed

mariadb-server, mariadb

Inherited from ubi10-httpd-php: php, php-mysqlnd, php-xml, php-mbstring, php-intl, php-gd, php-opcache, php-pecl-apcu
Inherited from ubi10-httpd: httpd
Inherited from ubi10-core: iputils, bind-utils, net-tools, less, cronie, procps-ng, diffutils

## Testing

- **Build test**: CI builds the image on every push to main/master
- **Smoke tests**: Service health (httpd, mariadb, php-fpm), MariaDB functional (CREATE DATABASE, CREATE TABLE, INSERT, SELECT, DROP DATABASE), package integrity, inherited package verification
- **Security scan**: Recommended (not yet implemented)

## Quality Gates

1. Build — CI builds the Containerfile successfully
2. Test — smoke tests pass (services up, MariaDB CRUD cycle works, packages verified)
3. Push — image published only after tests pass
4. Weekly rebuild — cron job picks up base image updates every Monday 4:45 AM UTC

## Downstream Consumers

WordPress and MediaWiki sites on lotor (crunchtools.com, educatedconfusion.com, us.crunchtools.com, learn.fatherlinux.com, test.crunchtools.com). Leaf image — no downstream container images.
