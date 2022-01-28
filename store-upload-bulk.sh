#!/usr/bin/env bash

set -eu -o pipefail

for folder in */ ; do
  if [[ "$folder" == "prepare-"[0-9]* ]]; then
    echo "Processing ${folder%/}";
    if [ -d "prepare" ] && (find prepare -type f | grep '' >/dev/null); then
      echo "!! Folder contains stuff, hanging."
      exit 1
    fi

    rm -rf prepare
    mv "${folder%/}" prepare
    ./store.sh
    ./upload.sh
  fi
done

