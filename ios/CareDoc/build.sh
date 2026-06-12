#!/bin/zsh
# Carrius — macOS 驗證版建置（不需 Xcode，CLT 即可）
# 用法：./build.sh        編譯並啟動
#       ./build.sh -b     只編譯
set -e
cd "$(dirname "$0")"
mkdir -p .build
echo "Compiling Carrius (macOS verification build)…"
swiftc -parse-as-library \
  -target arm64-apple-macosx14.0 \
  $(find Sources -name '*.swift') \
  -o .build/Carrius
echo "Build OK → .build/Carrius"
if [[ "$1" != "-b" ]]; then
  exec .build/Carrius
fi
