set -eu
source /app/crossfiles/amd64/env.sh
apk add --no-cache nasm
rustup target add x86_64-unknown-linux-musl
curl -sSL https://musl.cc/x86_64-linux-musl-cross.tgz | tar -zxf - -C /
git clone --branch 1.3.0 --depth 1 https://code.videolan.org/videolan/dav1d.git /dav1d
cd /dav1d
meson build -Dprefix=/app/dav1d -Denable_tools=false -Denable_examples=false -Ddefault_library=static --buildtype release --cross-file=/app/crossfiles/amd64/dav1d.meson 
ninja -C build && ninja -C build install
mkdir -p /x86_64-linux-musl-cross/app/dav1d/
cp -r /app/dav1d/lib /x86_64-linux-musl-cross/app/dav1d/lib
