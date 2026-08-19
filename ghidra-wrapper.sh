#!/bin/sh
set -eu

ghidra_user_home="${GHIDRA_USER_HOME:-/tmp/ghidra-home}"
mkdir -p "$ghidra_user_home"

export HOME="$ghidra_user_home"
export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-amd64}"
export _JAVA_OPTIONS="${_JAVA_OPTIONS:+${_JAVA_OPTIONS} }-Duser.home=${ghidra_user_home}"

case "${0##*/}" in
  analyzeHeadless)
    exec /opt/ghidra/support/analyzeHeadless "$@"
    ;;
  ghidra)
    exec /opt/ghidra/ghidraRun "$@"
    ;;
  *)
    echo "error: invoke this launcher as ghidra or analyzeHeadless" >&2
    exit 64
    ;;
esac
