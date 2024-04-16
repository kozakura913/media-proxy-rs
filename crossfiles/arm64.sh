rustup target add aarch64-unknown-linux-musl
curl -sSL https://musl.cc/aarch64-linux-musl-cross.tgz | tar -zxf - -C /
export PATH="/aarch64-linux-musl-cross/bin:${PATH}"
git clone --branch 1.3.0 --depth 1 https://code.videolan.org/videolan/dav1d.git /dav1d
cd /dav1d
export CC=aarch64-linux-musl-gcc
export AR=aarch64-linux-musl-ar
meson build -Dprefix=/app/dav1d -Denable_tools=false -Denable_examples=false -Ddefault_library=static --buildtype release --cross-file=/app/crossfiles/$TARGETARCH.meson 
ninja -C build
ninja -C build install
export PKG_CONFIG_PATH=/app/dav1d/lib/pkgconfig
export LD_LIBRARY_PATH=/app/dav1d/lib
export CARGO_HOME=/var/cache/cargo
export SYSTEM_DEPS_LINK=static
export RUSTFLAGS="-C link-args=-Wl,-lc -C linker=aarch64-linux-musl-gcc"
export PKG_CONFIG_SYSROOT_DIR="/aarch64-linux-musl-cross/"
export RUST_TARGET=aarch64-unknown-linux-musl
cp -r /app/dav1d/lib/* /aarch64-linux-musl-cross/lib/
cp -r /app/dav1d/include/dav1d /aarch64-linux-musl-cross/include/
