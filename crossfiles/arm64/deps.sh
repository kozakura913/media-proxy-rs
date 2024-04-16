set -eu
source /app/crossfiles/arm64/env.sh
rustup target add aarch64-unknown-linux-musl
curl -sSL https://musl.cc/aarch64-linux-musl-cross.tgz | tar -zxf - -C /
git clone --branch 1.3.0 --depth 1 https://code.videolan.org/videolan/dav1d.git /dav1d
cd /dav1d
meson build -Dprefix=/app/dav1d -Denable_tools=false -Denable_examples=false -Ddefault_library=static --buildtype release --cross-file=/app/crossfiles/arm64/dav1d.meson 
ninja -C build && ninja -C build install
mkdir -p /aarch64-linux-musl-cross/app/dav1d/
cp -r /app/dav1d/lib /aarch64-linux-musl-cross/app/dav1d/lib
