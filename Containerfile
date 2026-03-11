FROM quay.io/crunchtools/ubi10-httpd-php:latest

LABEL maintainer="fatherlinux <scott.mccarty@crunchtools.com>"
LABEL description="UBI 10 PHP + MariaDB leaf image for WordPress hosting — requires RHSM for mariadb-server"

# mariadb-server requires RHSM — register, install, unregister in single layer
RUN --mount=type=secret,id=RHSM_ACTIVATION_KEY \
    --mount=type=secret,id=RHSM_ORG_ID \
    subscription-manager register \
      --activationkey="$(cat /run/secrets/RHSM_ACTIVATION_KEY)" \
      --org="$(cat /run/secrets/RHSM_ORG_ID)" \
    && dnf install -y \
      mariadb-server \
      mariadb \
    && dnf clean all \
    && subscription-manager unregister

# Enable mariadb
RUN systemctl enable mariadb
