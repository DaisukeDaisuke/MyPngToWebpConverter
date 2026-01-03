#!/bin/sh
set -eu

cd /work

TOTAL=$(find . -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')
[ "$TOTAL" -eq 0 ] && exit 0

# 並列数（最大 8）
if [ "$TOTAL" -lt 8 ]; then
  PARALLEL="$TOTAL"
else
  PARALLEL=8
fi

COUNT_FILE="/tmp/webp_count.$$"
echo 0 > "$COUNT_FILE"

export TOTAL COUNT_FILE

find . -maxdepth 1 -type f -name '*.png' |
xargs -n 1 -P "$PARALLEL" sh -c '
  f="$1"
  out="${f%.png}.webp"

  convert "$f" \
    -define webp:lossless=true \
    -define webp:method=6 \
    "$out"

  # 進捗（簡易）
  count=$(cat "$COUNT_FILE")
  count=$((count + 1))
  echo "$count" > "$COUNT_FILE"

  percent=$((count * 100 / TOTAL))
  printf "\rconvert: %d/%d (%d%%)" "$count" "$TOTAL" "$percent"
' _

echo
rm -f "$COUNT_FILE"
