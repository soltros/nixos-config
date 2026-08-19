#!/usr/bin/env bash
# Fix permissions for Hermes system and user directories

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (e.g. sudo $0)." >&2
    exit 1
fi

TARGET_USER="${SUDO_USER:-derrik}"
TARGET_GROUP="$(id -gn "$TARGET_USER" 2>/dev/null || echo users)"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

echo "Fixing /var/lib/hermes permissions..."
if [ -d "/var/lib/hermes" ]; then
    chown -R hermes:hermes /var/lib/hermes
    chmod -R g+rwX /var/lib/hermes
    chmod 2770 /var/lib/hermes /var/lib/hermes/.hermes 2>/dev/null || true
    if command -v setfacl &>/dev/null; then
        setfacl -R -m d:g::rwx,g::rwx,d:g:hermes:rwx,g:hermes:rwx,d:m::rwx,m::rwx /var/lib/hermes 2>/dev/null || true
    fi
    echo "Fixed /var/lib/hermes."
fi

if [ -n "$TARGET_HOME" ] && [ -d "$TARGET_HOME/.hermes" ]; then
    echo "Fixing $TARGET_HOME/.hermes permissions for $TARGET_USER:$TARGET_GROUP..."
    chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.hermes"
    chmod 700 "$TARGET_HOME/.hermes"
    echo "Fixed $TARGET_HOME/.hermes."
fi

echo "Hermes permissions successfully fixed!"
