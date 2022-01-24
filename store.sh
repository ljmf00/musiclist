#!/usr/bin/env bash

set -eu -o pipefail

rm -rf ./prepare-tmp/ # avoid mixing files
mkdir -p ./prepare-tmp/
if [ -f .spotdl-cache ]; then
  mv .spotdl-cache ./prepare-tmp/
fi
spotdl "$@" --output-format mp3 --dt 8 --st 8 -o ./prepare-tmp/

mkdir -p ./prepare/
mv ./prepare-tmp/*.mp3 ./prepare/
mv ./prepare-tmp/.spotdl-cache .
rm -rf ./prepare-tmp/

mkdir -p ./store/metadata/temp/

shopt -s dotglob;
for file in ./prepare/* ; do
  FILE_CID_IPFS="$(ipfs add -n --pin=false --cid-version 1 -q "$file")"
  echo "$FILE_CID_IPFS"
  if find ./store/metatada/ -type f -name "$FILE_CID_IPFS" -exec false {} +; then
    exiftool -json "$file" > "./store/metadata/temp/$FILE_CID_IPFS"
  else
    ln -s "$(find ./store/metadata/ -type f -name "$FILE_CID_IPFS" | sed 's|^\.\/store\/metadata|\.\.|')" "./store/metadata/temp/$FILE_CID_IPFS"
    rm "$file"
  fi
done

touch ./store/cids
node index.js ./prepare/ > store.log
cat store.log >> ./store/cids

for file in ./prepare/* ; do
  rm "$file"
done
