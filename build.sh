#!/bin/bash

# extra credit: uazo

set -e
source vars.sh

cd $SRC_DIR
pwd

# install builds deps
# sudo build/install-build-deps-android.sh
# gclient runhooks

# generate ninja files and autogenerated files
gn gen --args="$(cat $BASE_DIR/bromite/build/bromite.gn_args) target_cpu=\"arm64\" " out/arm64

# build time!
# set NINJA_SUMMARIZE_BUILD=1
time autoninja -C out/arm64 system_webview_apk