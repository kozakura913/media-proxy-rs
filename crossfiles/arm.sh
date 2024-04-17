export MUSL_NAME="armv7l-linux-musleabihf-cross"
export PATH="/${MUSL_NAME}/bin:${PATH}"
export CC=armv7l-linux-musleabihf-gcc
export CXX=armv7l-linux-musleabihf-g++
export AR=armv7l-linux-musleabihf-ar
export CPU_FAMILY=arm
export TARGET_CPU=arm
export RUSTFLAGS="-C link-args=-Wl,-lc -C linker=clang -C link-arg=-fuse-ld=mold"
export PKG_CONFIG_SYSROOT_DIR="/${MUSL_NAME}/"
export RUST_TARGET="armv7-unknown-linux-musleabihf"
