#!/usr/bin/env bash

set -eu -o pipefail

./download.sh "$@"
./store.sh
./upload.sh
