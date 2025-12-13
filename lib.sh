#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/config.sh"

API_BASE="https://api.hetzner.cloud/v1"

hcurl() {
    curl -sS -H "Authorization: Bearer $HCLOUD_API_TOKEN" \
            -H "Content-Type: application/json" "$@"
}

quote_txt() {
    printf '"%s"' "$1"
}

# Determine the correct zone for a domain
get_zone() {
    local domain="$1"
    local zones json
    json=$(hcurl "$API_BASE/zones")
    # find longest matching suffix
    echo "$json" | jq -r --arg domain "$domain" '
        .zones[] | .name as $zone_name |
        select($domain|endswith($zone_name)) | $zone_name' \
        | awk '{ print length, $0 }' | sort -rn | head -n1 | cut -d' ' -f2
}

# Determine the rrset name relative to zone
get_rrset_name() {
    local domain="$1"
    local zone="$2"
    local relative="${domain%.${zone}}"  # remove zone suffix
    if [[ "$relative" == "$domain" ]]; then
        relative=""  # domain equals zone
    fi
    # prepend _acme-challenge
    if [[ -n "$relative" ]]; then
        echo "_acme-challenge.$relative"
    else
        echo "_acme-challenge"
    fi
}
