#!/bin/sh
set -eu

cd /work

TOTAL=$(find . -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')
[ "$TOTAL" -eq 0 ] && exit 0

COUNT=0
START=$(date +%s)

find . -maxdepth 1 -type f -name '*.png' |
while IFS= read -r f; do
  COUNT=$((COUNT + 1))
  out="${f%.png}.webp"

  convert "$f" \
    -define webp:lossless=true \
    -define webp:method=6 \
    "$out"

  NOW=$(date +%s)
  ELAPSED=$((NOW - START))
  percent=$((COUNT * 100 / TOTAL))

  printf '\rconvert: %d/%d (%d%%)' "$COUNT" "$TOTAL" "$percent"
done

echo
