#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function minify_and_normalize_freetz_cfg () {
  LANG=C sed -rf <(echo '
    /^\s*(#|$)/d
    ') -- "$@" | sort --version-sort
}


minify_and_normalize_freetz_cfg "$@"; exit $?
