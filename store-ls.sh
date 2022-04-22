#!/usr/bin/env bash

# Garanteed to contain no spaces, no need to use while read
#shellcheck disable=SC2013
(for blob in $(cat store/cids); do ipfs ls -s "/ipfs/$blob/prepare"; done) > store/cids-ls

#shellcheck disable=SC2002
comm -1 -2 \
  <(find store/metadata/ -type f -print0 | xargs -0 -I {} basename {} | sort) \
  <(cat store/cids-ls | cut -d' ' -f1 | sort)
