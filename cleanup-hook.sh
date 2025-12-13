#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

DOMAIN="$CERTBOT_DOMAIN"
VALUE="$CERTBOT_VALIDATION"

FILE="$TMP_DIR/$DOMAIN.txt"
if [[ ! -f "$FILE" ]]; then
    echo "No record info for $DOMAIN, skipping cleanup"
    exit 0
fi

read ZONE NAME VAL < <(awk -F'|' '{print $1,$2,$3}' "$FILE")

RESPONSE=$(hcurl -X POST "$API_BASE/zones/${ZONE}/rrsets/${NAME}/TXT/actions/remove_records" \
    -d "$(jq -n \
        --arg val "$(quote_txt "$VALUE")" \
        --arg comment "$TXT_COMMENT" \
        '{records:[{value:$val,comment:$comment}]}')"
)

rm -f "$FILE"
