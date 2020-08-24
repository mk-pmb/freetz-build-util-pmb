#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function again () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  chdir_to_repo_toplevel || return $?

  local TASK="${1:-reconsider}"; shift
  again_"$TASK" "$@" || return $?$(echo "E: $TASK rv=$?" >&2)
}


function chdir_to_repo_toplevel () {
  local CWD_PARENT="$(readlink -m -- "$(dirname -- "$PWD")")"
  [ "$CWD_PARENT" == "$SELFPATH" ] && return 0

  cd -- "$SELFPATH"/repo.current || return $?
}


function again_reconsider () {
  [ ! -f make.log ] || mv --no-target-directory \
    -- {,old_}make.log || return $?
  umask 0022
  >tail.make.log || return $?$(echo "E: Failed to truncate tail.make.log" >&2)
  make menuconfig || return $?
  make |& tee -- make.log
  local RV="${PIPESTATUS[*]}"
  again_chklog_prep || return $?
  case "$RV" in
    '0 0' )
      cp --no-target-directory -- .config{,.works}
      again_chklog_sxs || return $?
      return 0;;
    '2 0' )
      echo "E: make pipe rv: $RV" >&2
      again_chklog_err || return $?
      return 2;;
  esac
  echo "E: unexpected pipe statuses: $RV" >&2
  return 3
}


function again_chklog_prep () {
  tail --bytes=1K -- make.log | LANG=C sed -rf <(echo '
    s~\x1B\[[0-9;]*m~~g   # strip-color-codes
    ') | tail --lines=+2 >tail.make.log || return $?

  ( echo $'# -*- coding: utf-8, tab-width: 8 -*-\n'
    again_cfgdiff
  ) >'cfg.cmp' || return $?
}


function image_filesize_human () {
  local UNIT='MiB'
  echo "$(units --terse --output-format '%.2f' -- "$*" "$UNIT") $UNIT"
}


function again_chklog_sxs () {
  local IMGS_DIR='images'
  local CUR_IMG_LINK='latest-image.tar'
  local LATEST_IMGS=()
  readarray -t LATEST_IMGS < <(ls --format=single-column --sort=time \
      -- "$IMGS_DIR/" | grep -m 5 -Pe '\.image$')
  local CUR_IMG_NAME="${LATEST_IMGS[0]}"
  [ ! -L "$CUR_IMG_LINK" ] || rm -- "$CUR_IMG_LINK"
  ln --verbose --symbolic --no-target-directory \
    -- "$IMGS_DIR/$CUR_IMG_NAME" "$CUR_IMG_LINK"

  local IMG_SIZES=()
  local ITEM=
  for ITEM in "${LATEST_IMGS[@]}"; do
    ITEM="$(stat --format=%s -- "$IMGS_DIR/$ITEM")"
    ITEM="$(image_filesize_human "$ITEM bytes")"
    IMG_SIZES+=( "$ITEM" )
  done
  printf '\x1b[32mImage size:\x1b[0m %s' "${IMG_SIZES[0]}"
  ITEM="${IMG_SIZES[*]:1}"
  ITEM="${ITEM// MiB /, }"
  echo ", previous: $ITEM (later -> old)"
}


function again_chklog_err () {
  local TOOBIG="$(sed -nrf <(echo '
    s~^ERROR: (.* image) is ([0-9]+ bytes) too big\b~\2:\1\n~p
    ') -- tail.make.log | grep -m 1 -Pe '^\d')"
  [ -z "$TOOBIG" ] || echo $'\x1b[93mToo big:\x1b[0m'" ${TOOBIG#*:}: $(
    image_filesize_human "${TOOBIG%%:*}")"

  local HINTS="$("$SELFPATH"/make_fail_hints.sed -- tail.make.log)"
  if [ -n "$HINTS" ]; then
    echo
    echo $'\x1b[94m=== Hints: ====\x1b[0m'
    echo "$HINTS"
  fi
}


function again_cfgdiff () {
  local MAXLN=9009009
  local OTHER_CFG="${1:-.config.works}"
  local DATA_OTH="$(again_cfgdiff__parse "$OTHER_CFG")"
  local DATA_CUR="$(again_cfgdiff__parse .config)"
  local KEYS_OTH="$(<<<"$DATA_OTH" cut -d = -sf 1)"
  local KEYS_CUR="$(<<<"$DATA_CUR" cut -d = -sf 1)"
  local KEYS_DIFF="$(diff -U $MAXLN <(echo "$KEYS_OTH") <(echo "$KEYS_CUR"
    ) | tail --lines=+3)"
  diff -U $MAXLN -- <(<<<"$DATA_OTH" again_cfgdiff__blockify +
    ) <(<<<"$DATA_CUR" again_cfgdiff__blockify -
    ) | sed -nrf <(echo '
    /^\S==/p
    /^ == /{
      N
      /\n /b
      N
      s~^ == ([^\n]*)\n\-([^\n]*)\n\+([^\n]*)$~\2\t\3\t\1~
      p
    }
    ')
}


function again_cfgdiff__parse () {
  grep -Pe '^\w+=' -- "$@" | LANG=C sort -V
}


function again_cfgdiff__blockify () {
  local MISSING_VAR_SYM="$1"; shift
  (cat; <<<"$KEYS_DIFF" sed -nre 's~$~= ¤~;s!^\'"$MISSING_VAR_SYM!!p"
  ) | LANG=C sort -V | sed -re 's~=~\n~g;s~^~\n\n== ~;s~$~\n\n~'
}








[ "$1" == --lib ] && return 0; again "$@"; exit $?
