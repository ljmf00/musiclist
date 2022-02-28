#!/usr/bin/env bash

for blob in $(./store-ls.sh); do
  ipfs pin add "$blob" --progress;
done
