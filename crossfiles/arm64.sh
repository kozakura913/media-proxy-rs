export MUSL_NAME="aarch64-linux-musl-cross"
export PATH="/${MUSL_NAME}/bin:${PATH}"
export CC=aarch64-linux-musl-gcc
export CXX=aarch64-linux-musl-g++
export AR=aarch64-linux-musl-ar
export CPU_FAMILY=aarch64
export TARGET_CPU=aarch64
export RUSTFLAGS="-C link-args=-Wl,-lc -C linker=clang -C link-arg=-fuse-ld=mold"
export PKG_CONFIG_SYSROOT_DIR="/${MUSL_NAME}/"
export RUST_TARGET="aarch64-unknown-linux-musl"
