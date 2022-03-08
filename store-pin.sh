#!/usr/bin/env bash

if [[ "$1" == "shuffle " ]]; then
  FILES="$(./store-ls.sh | shuffle)"
else
  FILES="$(./store-ls.sh)"
fi

for blob in $FILES; do
  ipfs pin add "$blob" --progress;
done
