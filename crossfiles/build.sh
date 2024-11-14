set -eu
source /app/crossfiles/autoenv.sh
cp -r /dav1d/lib /musl/${MUSL_NAME}/dav1d/lib
mkdir ./.cargo/
echo "[target.${RUST_TARGET}]" >> ./.cargo/config.toml
echo 'rustflags = ["-C", "link-args=-Wl,-lc"]' >> ./.cargo/config.toml
cargo build --release --target ${RUST_TARGET}
cargo build --release --target ${RUST_TARGET} --example healthcheck
cp /app/target/${RUST_TARGET}/debug/media-proxy-rs /app/media-proxy-rs
cp /app/target/${RUST_TARGET}/release/examples/healthcheck /app/healthcheck
mkdir /app/libs
cp ${STDC_LIBS}/libstdc++.so* /app/libs
cp ${STDC_LIBS}/libgcc_s.so* /app/libs
