source /app/crossfiles/amd64/env.sh
cargo build --release --target --target ${RUST_TARGET}
cp /app/target/${RUST_TARGET}/release/media-proxy-rs /app/media-proxy-rs
