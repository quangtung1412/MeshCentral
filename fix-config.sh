#!/bin/bash
# Script này chạy sau khi container khởi động để fix TLSOffload

CONFIG_FILE="/opt/meshcentral/meshcentral-data/config.json"

# Đợi config file được tạo
while [ ! -f "$CONFIG_FILE" ]; do
    echo "Waiting for config.json..."
    sleep 2
done

# Bật TLSOffload nếu env variable được set
if [ "$TLS_OFFLOAD" = "true" ]; then
    echo "Setting TLSOffload to true..."
    jq '.settings.TLSOffload = true' "$CONFIG_FILE" > /tmp/config.json && mv /tmp/config.json "$CONFIG_FILE"
fi

echo "Config updated successfully"
cat "$CONFIG_FILE"
