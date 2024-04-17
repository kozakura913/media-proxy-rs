set -eu
if [ ${TARGETARCH} = ${BUILDARCH} ]; then
	export SYSTEM_DEPS_BUILD_INTERNAL=always
	export RUSTFLAGS="-C link-args=-Wl,-lc"
	cargo build --release
	cp /app/target/release/media-proxy-rs /app/media-proxy-rs
	exit 0
fi
source /app/crossfiles/${TARGETARCH}.sh
cargo build --release --target ${RUST_TARGET}
cp /app/target/${RUST_TARGET}/release/media-proxy-rs /app/media-proxy-rs
