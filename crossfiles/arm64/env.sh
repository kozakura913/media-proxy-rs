export MUSL_NAME="aarch64-linux-musl-cross"
export PATH="/${MUSL_NAME}/bin:${PATH}"
export CC=aarch64-linux-musl-gcc
export AR=aarch64-linux-musl-ar
export RUSTFLAGS="-C link-args=-Wl,-lc -C linker=${CC}"
export PKG_CONFIG_SYSROOT_DIR="/${MUSL_NAME}/"
export RUST_TARGET="aarch64-unknown-linux-musl"
