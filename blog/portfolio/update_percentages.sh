#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="portfolio.html"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "Error: file not found: $HTML_FILE" >&2
  exit 1
fi

echo "Paste 5 percentages (TSLA, MSTR, ARKG, CRSP, VAS), one per line."
echo "You can include or omit the % sign. Example: 12.34% or -3.1"
echo "When done, press Ctrl-D."
echo

pcts=()
while IFS= read -r line; do
  cleaned="$(printf '%s' "$line" | tr -d '\r' | sed -E 's/[[:space:]]+//g; s/%$//')"
  [[ -z "$cleaned" ]] && continue

  if [[ ! "$cleaned" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: invalid percentage line: '$line'" >&2
    exit 1
  fi

  pcts+=("$cleaned")
done

if [[ "${#pcts[@]}" -ne 5 ]]; then
  echo "Error: expected 5 percentages, got ${#pcts[@]}." >&2
  exit 1
fi

TSLA_P="${pcts[0]}"
MSTR_P="${pcts[1]}"
ARKG_P="${pcts[2]}"
CRSP_P="${pcts[3]}"
VAS_P="${pcts[4]}"

cp -a "$HTML_FILE" "$HTML_FILE.pct.bak"

# Percent update assumes ticker lines contain something like "(12.34%)"
if ! vim -Es "$HTML_FILE" \
  -c "%s/^\(\s*TSLA:.*(\)\zs-\?[0-9.]\+\ze%)/$TSLA_P/e" \
  -c "%s/^\(\s*MSTR:.*(\)\zs-\?[0-9.]\+\ze%)/$MSTR_P/e" \
  -c "%s/^\(\s*ARKG:.*(\)\zs-\?[0-9.]\+\ze%)/$ARKG_P/e" \
  -c "%s/^\(\s*CRSP:.*(\)\zs-\?[0-9.]\+\ze%)/$CRSP_P/e" \
  -c "%s/^\(\s*VAS:.*(\)\zs-\?[0-9.]\+\ze%)/$VAS_P/e" \
  -c "wq"
then
  echo "Error: vim failed. Backup kept at: $HTML_FILE.pct.bak" >&2
  exit 1
fi

echo "Percentages updated."
echo "Backup saved as $HTML_FILE.pct.bak"

