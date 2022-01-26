#!/usr/bin/env bash

./download.sh "$@"
./store.sh
./upload.sh
