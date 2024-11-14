export MUSL_NAME="x86_64-linux-musl-cross"
export PATH="/musl/${MUSL_NAME}/bin:${PATH}"
export CC=x86_64-linux-musl-gcc
export CXX=x86_64-linux-musl-g++
export AR=x86_64-linux-musl-ar
export RUSTFLAGS="-C target-feature=+avx -C linker=${CC}"
export PKG_CONFIG_SYSROOT_DIR="/musl/${MUSL_NAME}/"
export RUST_TARGET="x86_64-unknown-linux-musl"
export STDC_LIBS="/musl/${MUSL_NAME}/x86_64-linux-musl/lib"
