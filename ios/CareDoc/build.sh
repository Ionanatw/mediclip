#!/bin/zsh
# Carrius — macOS 驗證版建置（不需 Xcode，CLT 即可）
# 用法：./build.sh        編譯並啟動
#       ./build.sh -b     只編譯
#
# 注意：此機 CLT 安裝損壞（usr/include/swift 同時存在 module.modulemap 與
# bridging.modulemap，重複定義 SwiftBridging）。以下用 VFS overlay 把舊檔
# 虛擬替換成空檔繞過，不動系統檔案。永久修法（需 sudo）：
#   sudo rm /Library/Developer/CommandLineTools/usr/include/swift/module.modulemap
set -e
cd "$(dirname "$0")"
mkdir -p .build
touch .build/empty.modulemap
cat > .build/clt-fix-overlay.yaml <<EOF
{
  "version": 0,
  "case-sensitive": "false",
  "use-external-names": false,
  "roots": [
    {
      "name": "/Library/Developer/CommandLineTools/usr/include/swift",
      "type": "directory",
      "contents": [
        { "name": "module.modulemap", "type": "file",
          "external-contents": "$PWD/.build/empty.modulemap" }
      ]
    }
  ]
}
EOF
echo "Compiling Carrius (macOS verification build)…"
swiftc -parse-as-library -Onone \
  -target arm64-apple-macosx14.0 \
  -module-cache-path .build/module-cache \
  -vfsoverlay .build/clt-fix-overlay.yaml \
  -Xcc -ivfsoverlay -Xcc .build/clt-fix-overlay.yaml \
  $(find Sources -name '*.swift') \
  -o .build/Carrius
echo "Build OK → .build/Carrius"
if [[ "$1" != "-b" ]]; then
  exec .build/Carrius
fi
