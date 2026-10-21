FROM quay.io/crunchtools/ubi10-httpd-php:latest

LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="UBI 10 PHP + MariaDB leaf image for WordPress hosting — requires RHSM for mariadb-server"

# mariadb-server requires RHSM — register, install, unregister in single layer.
# While registered, also upgrade PHP from RHEL AppStream: RHEL errata can land
# hours before the UBI repos sync (CVE-2026-109618/109619 shipped as 8.3.36 in
# RHEL on disclosure day while UBI still had 8.3.33).
RUN --mount=type=secret,id=RHSM_ACTIVATION_KEY \
    --mount=type=secret,id=RHSM_ORG_ID \
    subscription-manager register \
      --activationkey="$(cat /run/secrets/RHSM_ACTIVATION_KEY)" \
      --org="$(cat /run/secrets/RHSM_ORG_ID)" \
    && dnf install -y \
      mariadb-server \
      mariadb \
    && dnf upgrade -y 'php*' \
    && dnf clean all \
    && subscription-manager unregister

# Enable mariadb
RUN systemctl enable mariadb

# CrunchTools: self-heal MariaDB on failure (incl. OOM) via systemd drop-in.
COPY config/mariadb-restart.conf /etc/systemd/system/mariadb.service.d/restart.conf
