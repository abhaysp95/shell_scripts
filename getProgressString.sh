#!/usr/bin/bash

# getProgressString.sh <Total> <Filled look> <Not filled look> <status>

ITEMS="$1"
FILLED_ITEM="$2"
NOT_FILLED_ITEM="$3"
STATUS="$4"

# calculate how many to fill and not fill

FILLED_ITEMS=$(echo "((${ITEMS} * ${STATUS}) / 100 + 0.5) / 1" | bc)
NOT_FILLED_ITEMS=$(echo "${ITEMS} - ${FILLED_ITEMS}" | bc)

msg="$(printf "%${FILLED_ITEMS}s" | sed "s| |${FILLED_ITEM}|g")"
# msg="$(printf "%s%${NOT_FILLED_ITEMS}s" "hello" | sed "s| |${NOT_FILLED_ITEM}|g")"
msg=${msg}$(printf "%s%${NOT_FILLED_ITEMS}s" | sed "s| |${NOT_FILLED_ITEM}|g")
echo "${msg}"
