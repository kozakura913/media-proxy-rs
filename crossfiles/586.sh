export MUSL_NAME="i486-linux-musl-cross"
export PATH="/${MUSL_NAME}/bin:${PATH}"
export CC=i486-linux-musl-gcc
export CXX=i486-linux-musl-g++
export AR=i486-linux-musl-ar
export RUSTFLAGS="-C linker=${CC}"
export PKG_CONFIG_SYSROOT_DIR="/${MUSL_NAME}/"
export RUST_TARGET="i586-unknown-linux-musl"
