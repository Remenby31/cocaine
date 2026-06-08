#!/bin/bash
# Setup sudoers rule so NoSleep can call pmset without password prompt
# Run once: sudo bash setup-sudoers.sh

SUDOERS_FILE="/etc/sudoers.d/nosleep-pmset"

if [ "$EUID" -ne 0 ]; then
    echo "Run with sudo: sudo bash $0"
    exit 1
fi

echo "%admin ALL=(ALL) NOPASSWD: /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset -a disablesleep 0" > "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"
echo "Done — pmset disablesleep allowed without password for admin users."
