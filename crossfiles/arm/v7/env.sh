export PATH="/armv7l-linux-musleabihf-cross/bin:${PATH}"
export CC=armv7l-linux-musleabihf-gcc
export AR=armv7l-linux-musleabihf-ar
export RUSTFLAGS="-C link-args=-Wl,-lc -C linker=${CC}"
export PKG_CONFIG_SYSROOT_DIR="/armv7-linux-musl-cross/"
export RUST_TARGET="armv7-unknown-linux-musleabihf"
