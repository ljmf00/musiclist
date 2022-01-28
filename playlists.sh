#!/usr/bin/env bash

./mkplaylists.d --localhost
rsync -avh --delete --progress "playlists/" "$HOME/Sync/playlists/local-store/"
./mkplaylists.d
rsync -avh --delete --progress "playlists/" "$HOME/Sync/playlists/store/"

