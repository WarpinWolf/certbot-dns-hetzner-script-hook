#!/usr/bin/env bash
# Copy to config.sh and fill in your token
HCLOUD_API_TOKEN="YOUR_CLOUD_API_TOKEN"
TXT_COMMENT="certbot-hetzner"
TTL=60
TMP_DIR="/tmp/certbot-hetzner"
mkdir -p "$TMP_DIR"
