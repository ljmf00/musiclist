#!/usr/bin/env bash

set -eu -o pipefail

touch ./store/cids
node index.js ./prepare/ > store.log
cat store.log >> ./store/cids

for file in ./prepare/* ; do
  rm "$file"
done

