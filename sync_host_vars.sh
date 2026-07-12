#!/bin/bash

INVENTORY="inventory"
HOST_VARS_DIR="host_vars"
PRIVATE_KEY="$HOME/Downloads/kirtan-key.pem"

mkdir -p "$HOST_VARS_DIR"

echo "Starting host_vars sync..."

while IFS= read -r line <&3
do

    # Skip empty lines and groups
    [[ -z "$line" || "$line" =~ ^\[.*\]$ ]] && continue

    HOST=$(echo "$line" | awk '{print $1}')
    USER=$(echo "$line" | grep -o "ansible_user=[^ ]*" | cut -d= -f2)

    [[ -z "$HOST" || -z "$USER" ]] && continue

    echo "--------------------------------"
    echo "Checking $HOST as $USER"

    OS=$(ssh \
        -i "$PRIVATE_KEY" \
        -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=no \
        "$USER@$HOST" \
        "grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '\"'" \
        </dev/null)


    if [[ "$OS" == "ubuntu" ]]; then

cat > "$HOST_VARS_DIR/$HOST.yml" <<EOF
apache_package_name: apache2
apache_service: apache2
php_package_name: libapache2-mod-php
EOF

        echo "$HOST is Ubuntu"


    elif [[ "$OS" == "amzn" ]]; then

cat > "$HOST_VARS_DIR/$HOST.yml" <<EOF
apache_package_name: httpd
apache_service: httpd
php_package_name: php
EOF

        echo "$HOST is Amazon Linux"


    else
        echo "Unknown OS: $OS"
    fi


done 3< "$INVENTORY"


echo "Finished!"
