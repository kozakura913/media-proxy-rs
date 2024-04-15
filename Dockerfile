FROM rust:bookworm
RUN apt-get update && apt-get install curl meson ninja-build pkg-config git
RUN sh -c "if [ $(uname -m) = x86_64 ]; then apt-get update && apt-get install nasm;fi"
RUN curl -sSL https://github.com/mozilla/sccache/releases/download/v0.7.7/sccache-v0.7.7-x86_64-unknown-linux-musl.tar.gz | tar -zxf - -C /tmp && mv /tmp/sccache*/sccache /usr/local/bin && rm -rf /tmp/sccache*
ENV CARGO_HOME=/var/cache/cargo
RUN mkdir /app
ENV SYSTEM_DEPS_BUILD_INTERNAL=always
ENV RUSTFLAGS="-C link-args=-Wl,-lc"
WORKDIR /app
COPY avif-decoder_dep ./avif-decoder_dep
COPY src ./src
COPY Cargo.toml ./Cargo.toml
ENV RUSTC_WRAPPER=/usr/local/bin/sccache
ENV SCCACHE_DIR=/var/cache/sccache
RUN --mount=type=cache,target=/var/cache/cargo --mount=type=cache,target=/var/cache/sccache cargo build --release

FROM debian:bookworm
ARG UID="852"
ARG GID="852"
RUN groupadd -g "${GID}" media-proxy && useradd -u "${UID}" -g "${GID}" -d /media-proxy-rs -s /bin/sh media-proxy
WORKDIR /media-proxy-rs
RUN chown -R media-proxy:media-proxy /media-proxy-rs
USER media-proxy
COPY asset ./asset
COPY --from=0 /app/target/release/media-proxy-rs ./media-proxy-rs
EXPOSE 12766
CMD ["./media-proxy-rs"]
