#!/usr/bin/env bash

./mkplaylists.d
rsync -avh --progress "playlists/" "$HOME/Sync/playlists/store/"

