#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202207101834-git
# @Author            :  Jason Hempstead
# @Contact           :  jason@casjaysdev.com
# @License           :  LICENSE.md
# @ReadME            :  deno-init.sh --help
# @Copyright         :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @Created           :  Sunday, Jul 10, 2022 18:34 EDT
# @File              :  deno-init.sh
# @Description       :  Download binaries for amd64 and arm64
# @TODO              :
# @Other             :
# @Resource          :
# @sudo/root         :  no
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ -n "$DEBUG" ] && set -x
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DENO_VERSION="${DENO_VERSION:-v1.26.1}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x86_64" ]; then
  ARCH="x86_64"
  CHANNEL="github.com/denoland/deno"
  URL="https://github.com/denoland/deno/releases/download/$DENO_VERSION/deno-$ARCH-unknown-linux-gnu.zip"
  BIN_FILE="/usr/bin/deno"
  TMP_DIR="/tmp/deno-$ARCH"
  TMP_FILE="/tmp/deno-$ARCH.zip"
elif [ "$(uname -m)" = "arm64" ] || [ "$(uname -m)" = "aarch64" ]; then
  ARCH="arm64"
  CHANNEL="github.com/LukeChannings/deno-arm64"
  URL="https://github.com/LukeChannings/deno-arm64/releases/download/$DENO_VERSION/deno-linux-$ARCH.zip"
  BIN_FILE="/usr/bin/deno"
  TMP_DIR="/tmp/deno-$ARCH"
  TMP_FILE="/tmp/deno-$ARCH.zip"
else
  echo "Unsupported architecture"
  exit 1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
echo "grabbing deno $DENO_VERSION from $CHANNEL for $ARCH"
if curl -q -LSsf -o "$TMP_FILE" "$URL" && [ -f "$TMP_FILE" ]; then
  mkdir -p "$TMP_DIR" && cd "$TMP_DIR" || exit 10
  unzip -q "$TMP_FILE"
  if [ -f "$TMP_DIR/deno" ]; then
    cp -Rf "$TMP_DIR/deno" "$BIN_FILE" && chmod -Rf 755 "$BIN_FILE" || exitCode=10
    [ -f "$BIN_FILE" ] && $BIN_FILE upgrade && exitCode=0 || exitCode=10
  else
    echo "Failed to extract deno from $TMP_FILE"
    exitCode=10
  fi
else
  echo "Failed to download deno from $URL"
  exitCode=2
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
rm -Rf "$TMP_FILE" "$TMP_DIR"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit ${exitCode:-0}
