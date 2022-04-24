#!/usr/bin/env bash

set -eu -o pipefail

if [ -d "prepare" ] && (find prepare -type f | grep '' >/dev/null); then
  touch ./store/cids
  ipfs add --cid-version 1 ./prepare/*
  node index.js ./prepare/ > store.log
  cat store.log >> ./store/cids

  for file in ./prepare/* ; do
    rm "$file"
  done
fi
