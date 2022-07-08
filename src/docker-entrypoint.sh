#!/bin/bash
set -e

mkdir -p "/home/opuser/.op"
echo "$OP_BASE64_CREDENTIALS" | base64 -d > /home/opuser/.op/1password-credentials.json

if [ -f "/home/opuser/supervisor.sock" ]; then
    rm -f "/home/opuser/supervisor.sock"
fi

echo "Starting container..."
exec "$@"
