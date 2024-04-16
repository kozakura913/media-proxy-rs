export PATH="/x86_64-linux-musl-cross/bin:${PATH}"
export CC=x86_64-linux-musl-gcc
export AR=x86_64-linux-musl-ar
export RUSTFLAGS="-C link-args=-Wl,-lc -C linker=${CC}"
export PKG_CONFIG_SYSROOT_DIR="/x86_64-linux-musl-cross/"
export RUST_TARGET="x86_64-unknown-linux-musl"
