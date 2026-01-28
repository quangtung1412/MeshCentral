#!/bin/bash
# Generate config.json từ template + .env
# Chạy script này trước khi docker compose up

set -e

if [ ! -f .env ]; then
    echo "❌ .env file not found! Copy .env.example to .env first"
    echo "   cp .env.example .env"
    exit 1
fi

# Load .env
export $(grep -v '^#' .env | xargs)

# Read template
CONFIG_TEMPLATE=$(cat config.json)

# Replace placeholders
CONFIG_RUNTIME=$(echo "$CONFIG_TEMPLATE" | \
    sed "s/HOSTNAME_PLACEHOLDER/$HOSTNAME/g" | \
    sed "s/DB_PASSWORD_PLACEHOLDER/$MYSQL_PASSWORD/g" | \
    sed "s/NEW_ACCOUNTS_PLACEHOLDER/$ALLOW_NEW_ACCOUNTS/g")

# Write runtime config
echo "$CONFIG_RUNTIME" > config.runtime.json

echo "✅ Generated config.runtime.json from config.json template"
echo "Now run: docker compose up -d"
