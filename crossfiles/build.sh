set -eu
if [ -f "/app/crossfiles/${TARGETARCH}.sh" ]; then
	source /app/crossfiles/${TARGETARCH}.sh
else
	source /app/crossfiles/${TARGETARCH}/${TARGETVARIANT}.sh
fi
cargo build --release --target ${RUST_TARGET}
cp /app/target/${RUST_TARGET}/release/media-proxy-rs /app/media-proxy-rs
