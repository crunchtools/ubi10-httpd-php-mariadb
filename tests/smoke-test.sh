#!/bin/bash
# smoke-test.sh — smoke tests for ubi10-httpd-php-mariadb container image
# Run inside a running container started with --systemd=always
# Exit 0 = all pass, Exit 1 = one or more failures

set -uo pipefail

FAILURES=0
TESTS=0

pass() {
    TESTS=$((TESTS + 1))
    echo "  PASS: $1"
}

fail() {
    TESTS=$((TESTS + 1))
    FAILURES=$((FAILURES + 1))
    echo "  FAIL: $1"
}

# ---------- Service Health ----------
echo "=== Service Health ==="

for svc in httpd mariadb php-fpm; do
    if systemctl is-active "$svc" >/dev/null 2>&1; then
        pass "$svc is active"
    else
        fail "$svc is not active"
    fi
done

# ---------- MariaDB Functional Tests ----------
echo "=== MariaDB Functional Tests ==="

DB_NAME="smoke_test_db"

# CREATE DATABASE
if mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" 2>/dev/null; then
    pass "CREATE DATABASE ${DB_NAME}"
else
    fail "CREATE DATABASE ${DB_NAME}"
fi

# CREATE TABLE
if mysql -e "CREATE TABLE ${DB_NAME}.test_table (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(50));" 2>/dev/null; then
    pass "CREATE TABLE test_table"
else
    fail "CREATE TABLE test_table"
fi

# INSERT
if mysql -e "INSERT INTO ${DB_NAME}.test_table (name) VALUES ('smoke_test');" 2>/dev/null; then
    pass "INSERT INTO test_table"
else
    fail "INSERT INTO test_table"
fi

# SELECT
RESULT=$(mysql -N -e "SELECT name FROM ${DB_NAME}.test_table WHERE name='smoke_test';" 2>/dev/null)
if [ "$RESULT" = "smoke_test" ]; then
    pass "SELECT returns correct value"
else
    fail "SELECT returned '$RESULT' instead of 'smoke_test'"
fi

# DROP DATABASE
if mysql -e "DROP DATABASE ${DB_NAME};" 2>/dev/null; then
    pass "DROP DATABASE ${DB_NAME}"
else
    fail "DROP DATABASE ${DB_NAME}"
fi

# ---------- Package Integrity ----------
echo "=== Package Integrity ==="

PACKAGES=(mariadb-server mariadb)
for pkg in "${PACKAGES[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
        pass "package: $pkg"
    else
        fail "package missing: $pkg"
    fi
done

# ---------- Inherited (ubi10-httpd-php) ----------
echo "=== Inherited (ubi10-httpd-php) ==="

INHERITED_PACKAGES=(httpd php php-mysqlnd php-xml php-mbstring php-intl php-gd php-opcache php-pecl-apcu)
for pkg in "${INHERITED_PACKAGES[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
        pass "inherited package: $pkg"
    else
        fail "inherited package missing: $pkg"
    fi
done

# ---------- Inherited (ubi10-core) ----------
echo "=== Inherited (ubi10-core) ==="

CORE_PACKAGES=(iputils bind-utils net-tools less cronie procps-ng diffutils)
for pkg in "${CORE_PACKAGES[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
        pass "inherited package: $pkg"
    else
        fail "inherited package missing: $pkg"
    fi
done

# ---------- Summary ----------
echo ""
echo "=== Results: $((TESTS - FAILURES))/$TESTS passed ==="

if [ "$FAILURES" -gt 0 ]; then
    echo "$FAILURES test(s) failed"
    exit 1
fi

echo "All tests passed"
exit 0
