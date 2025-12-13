#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

DOMAIN="$CERTBOT_DOMAIN"
VALUE="$CERTBOT_VALIDATION"
TTL="${TTL:-60}"

ZONE=$(get_zone "$DOMAIN")
if [[ -z "$ZONE" ]]; then
    echo "ERROR: No zone found for $DOMAIN"
    exit 1
fi

NAME=$(get_rrset_name "$DOMAIN" "$ZONE")

# Add TXT record
RESPONSE=$(hcurl -X POST "$API_BASE/zones/${ZONE}/rrsets/${NAME}/TXT/actions/add_records" \
    -d "$(jq -n \
        --arg ttl "$TTL" \
        --arg val "$(quote_txt "$VALUE")" \
        --arg comment "$TXT_COMMENT" \
        '{ttl:($ttl|tonumber), records:[{value:$val,comment:$comment}]}')"
)

# Store mapping for cleanup
echo "$ZONE|$NAME|$VALUE" > "$TMP_DIR/$DOMAIN.txt"

# Optional wait for DNS propagation
sleep 30
