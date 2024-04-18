export MUSL_NAME="armv7l-linux-musleabihf-cross"
export PATH="/${MUSL_NAME}/bin:${PATH}"
export CC=armv7l-linux-musleabihf-gcc
export CXX=armv7l-linux-musleabihf-g++
export AR=armv7l-linux-musleabihf-ar
export CPU_FAMILY=arm
export TARGET_CPU=armv7
export RUSTFLAGS="-C link-args=-Wl,-lc -C linker=${CC}"
export PKG_CONFIG_SYSROOT_DIR="/${MUSL_NAME}/"
export RUST_TARGET="armv7-unknown-linux-musleabihf"
cat <<EOF > /dav1d/crossfile.meson
[built-in options]
c_args      = ['-marm']
cpp_args    = ['-marm']
EOF
