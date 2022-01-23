#!/usr/bin/env bash

set -eu -o pipefail

mkdir -p ./prepare-tmp/
spotdl "$@" --output-format mp3 --dt 8 --st 8 -o ./prepare-tmp/

mkdir -p ./prepare/
mv ./prepare-tmp/*.mp3 ./prepare/
rm -rf ./prepare-tmp/

touch store-cids
node index.js ./prepare/ > store.log
cat store.log >> store-cids

mkdir -p ./store/all/

shopt -s dotglob;
for file in ./prepare/* ; do
  echo "$file";
  FILE_CID_IPFS="$(ipfs add -n --pin=false --cid-version 1 -q "$file")"
  if ! find ./store/ -name "$FILE_CID_IPFS"; then
    exiftool -json "$file" > "./store/all/$FILE_CID_IPFS"
  fi
  rm "$file"
done

