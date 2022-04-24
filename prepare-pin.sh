#!/usr/bin/env bash

set -eu -o pipefail

if [ -d "prepare" ] && (find prepare -type f | grep '' >/dev/null); then
  echo "!! Folder contains stuff, hanging."
  exit 1
fi

./download.sh "$@"
./store.sh
./upload-pin.sh
