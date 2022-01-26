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
