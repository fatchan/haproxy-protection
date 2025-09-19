#!/usr/bin/env bash
source "/usr/lib/emsdk/emsdk_env.sh"
emcc challenge.c -o chbtn.js -s EXPORTED_FUNCTIONS='["_cstart_size", "_outline_color", "_increment_position"]' -s MODULARIZE=1 -s EXPORT_NAME='createChallengeModule' -s WASM=1 -s SINGLE_FILE=1 -O3 --closure 1
cp chbtn.js ../js/bc.js
