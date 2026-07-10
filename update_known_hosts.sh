#!/bin/bash

INVENTORY="inventory"
KNOWN_HOSTS="$HOME/.ssh/known_hosts"

mkdir -p "$HOME/.ssh"
touch "$KNOWN_HOSTS"

echo "Updating SSH known_hosts..."

grep -Ev '^\s*$|^\s*#|^\[' "$INVENTORY" | while read -r line
do
    HOST=$(echo "$line" | awk '{print $1}')

    echo "Updating $HOST..."

    # Remove any old host key
    ssh-keygen -R "$HOST" -f "$KNOWN_HOSTS" >/dev/null 2>&1

    # Fetch and add the new host key
    ssh-keyscan -H "$HOST" >> "$KNOWN_HOSTS" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Added $HOST"
    else
        echo "✗ Failed to scan $HOST"
    fi
done

echo ""
echo "Done!"
echo "Known hosts updated: $KNOWN_HOSTS"
