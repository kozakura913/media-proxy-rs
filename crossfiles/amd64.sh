export MUSL_NAME="x86_64-linux-musl-cross"
export PATH="/${MUSL_NAME}/bin:${PATH}"
export CC=x86_64-linux-musl-gcc
export CXX=x86_64-linux-musl-g++
export AR=x86_64-linux-musl-ar
export CPU_FAMILY=x86_64
export TARGET_CPU=x86_64
export RUSTFLAGS="-C target-feature=+avx -C link-args=-Wl,-lc -C linker=clang -C link-arg=-fuse-ld=mold"
export PKG_CONFIG_SYSROOT_DIR="/${MUSL_NAME}/"
export RUST_TARGET="x86_64-unknown-linux-musl"
