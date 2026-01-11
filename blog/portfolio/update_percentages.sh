#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="blog/portfolio/portfolio.html"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "Error: file not found: $HTML_FILE" >&2
  exit 1
fi

echo "Paste 5 percentages (TSLA, MSTR, ARKG, CRSP, VAS), one per line."
echo "You can paste with or without the % sign (e.g. 98.30% or 98.30)."
echo "When done, press Ctrl-D."
echo

pcts=()
while IFS= read -r line; do
  # strip CRLF, spaces, trailing %
  cleaned="$(printf '%s' "$line" | tr -d '\r' | sed -E 's/[[:space:]]+//g; s/%$//')"
  [[ -z "$cleaned" ]] && continue

  if [[ ! "$cleaned" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
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

# Backup
cp -a "$HTML_FILE" "$HTML_FILE.pct.bak"

# Updates the number after "TICKER:" and before the "%" sign.
if ! vim -Es "$HTML_FILE" \
  -c "%s/^\(\\s*TSLA:\\s*\\)\\zs[0-9.][0-9.]*/$TSLA_P/e" \
  -c "%s/^\(\\s*MSTR:\\s*\\)\\zs[0-9.][0-9.]*/$MSTR_P/e" \
  -c "%s/^\(\\s*ARKG:\\s*\\)\\zs[0-9.][0-9.]*/$ARKG_P/e" \
  -c "%s/^\(\\s*CRSP:\\s*\\)\\zs[0-9.][0-9.]*/$CRSP_P/e" \
  -c "%s/^\(\\s*VAS:\\s*\\)\\zs[0-9.][0-9.]*/$VAS_P/e" \
  -c "wq"
then
  echo "Error: vim failed to update the file. Backup kept at: $HTML_FILE.pct.bak" >&2
  exit 1
fi

echo "Percentages updated."
echo "Backup saved as $HTML_FILE.pct.bak"

