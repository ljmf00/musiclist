#!/usr/bin/env bash

set -eu -o pipefail

mkdir -p ./store/metadata/temp/

shopt -s dotglob;
for file in ./prepare/* ; do
  FILE_CID_IPFS="$(ipfs add -n --pin=false --cid-version 1 -q "$file")"
  echo "$FILE_CID_IPFS"
  if find ./store/metadata/ -type f -name "$FILE_CID_IPFS" -exec false {} +; then
    exiftool -json "$file" > "./store/metadata/temp/$FILE_CID_IPFS"
  else
    if [ ! -f "./store/metadata/temp/$FILE_CID_IPFS" ]; then
      ln -s "$(find ./store/metadata/ -type f -name "$FILE_CID_IPFS" | sed 's|^\.\/store\/metadata|\.\.|')" "./store/metadata/temp/$FILE_CID_IPFS"
    fi
    rm "$file"
  fi
done
