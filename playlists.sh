#!/usr/bin/env bash

./mkplaylists.d --localhost
rsync -avh --progress "playlists/" "$HOME/Sync/playlists/local-store/"
./mkplaylists.d
rsync -avh --progress "playlists/" "$HOME/Sync/playlists/store/"

