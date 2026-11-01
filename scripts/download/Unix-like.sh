#!/bin/sh
set -eu
echo ::group::Downloading bclone $version for $RUNNER_OS $RUNNER_ARCH
if [ $RUNNER_OS = macOS ]; then os=osx; else os=linux; fi
if [ $RUNNER_ARCH = ARM64 ]; then arch=arm64; else arch=amd64; fi
base=$GITHUB_SERVER_URL/benjithatfoxguy/bclone/releases/download/$version

# Releases from v1.76.0 ship bclone-*.zip holding a "bclone" binary; older
# ones ship rclone-*.zip holding "rclone".
zip=
for name in bclone rclone; do
  if wget -q "$base/$name-$version-$os-$arch.zip"; then
    zip=$name-$version-$os-$arch.zip
    break
  fi
done
if [ -z "$zip" ]; then
  echo "::error::No bclone or rclone archive found for $version $os-$arch"
  exit 1
fi

mkdir -p Rclone
unzip -jq "$zip" $(unzip -Z1 "$zip" | grep -E '/[br]clone$') -d Rclone
rm "$zip"

# Provide both command names whichever one the archive had
if [ ! -e Rclone/rclone ]; then ln -s bclone Rclone/rclone; fi
if [ ! -e Rclone/bclone ]; then ln -s rclone Rclone/bclone; fi
echo ::endgroup::
