#!/bin/bash
set -euo pipefail

# Fix permissions for bind-mounted files from Windows
fix_perms() {
    local path="$1"
    local mode="${2:-644}"
    if [[ -e "$path" ]]; then
        sudo chown "$(whoami):$(whoami)" "$path" 2>/dev/null || true
        chmod "$mode" "$path" 2>/dev/null || true
    fi
}

# SSH requires strict permissions
if [[ -d "$HOME/.ssh" ]]; then
    sudo chown -R "$(whoami):$(whoami)" "$HOME/.ssh" 2>/dev/null || true
    chmod 700 "$HOME/.ssh" 2>/dev/null || true
    chmod 600 "$HOME/.ssh"/* 2>/dev/null || true
fi

# .gitconfig is read-only mount, skip it
fix_perms "$HOME/.bash_aliases" 644

# Check data mount status
MOUNT_POINT="/data"
if mountpoint -q "$MOUNT_POINT" 2>/dev/null; then
    echo "Data mounted at $MOUNT_POINT"
else
    echo "No data mount. Set ONEDRIVE env var on host for OneDrive mount."
fi

echo "Post-create setup complete."
