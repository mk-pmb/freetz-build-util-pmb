#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function again () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH"/repo.current || return $?
  
  local TASK="${1:-reconsider}"; shift
  again_"$TASK" "$@" || return $?
}


function again_chkbig () {
  local BIG="$(tail --bytes=1K make.log | strip-color-codes \
    | grep -oPie '^ERROR: combined .* image is \d+(?= bytes too big)' \
    | grep -oPe '\d+$')"
  echo "big=$BIG"
}


function again_reconsider () {
  [ ! -f make.log ] || mv --no-target-directory \
    -- {,old_}make.log || return $?
  umask 0022
  make menuconfig || return $?
  make |& tee -- make.log
  local RV="${PIPESTATUS[*]}"
  case "$RV" in
    * ) echo "E: unexpected pipe statuses: $RV" >&2; return 3;;
  esac
}








[ "$1" == --lib ] && return 0; again "$@"; exit $?
