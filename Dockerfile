FROM --platform=$BUILDPLATFORM rust:alpine
ARG BUILDARCH
ARG TARGETARCH
RUN apk add --no-cache clang musl-dev curl meson ninja pkgconfig git
ENV PATH="/aarch64-linux-musl-cross/bin:${PATH}"
ENV CC=aarch64-linux-musl-gcc
ENV AR=aarch64-linux-musl-ar
ENV PKG_CONFIG_PATH=/app/dav1d/lib/pkgconfig
ENV LD_LIBRARY_PATH=/app/dav1d/lib
ENV CARGO_HOME=/var/cache/cargo
ENV SYSTEM_DEPS_LINK=static
ENV RUSTFLAGS="-C link-args=-Wl,-lc -C linker=aarch64-linux-musl-gcc"
ENV PKG_CONFIG_SYSROOT_DIR="/aarch64-linux-musl-cross/"
COPY crossfiles /app/crossfiles
RUN sh /app/crossfiles/arm64.sh
WORKDIR /app
COPY avif-decoder_dep ./avif-decoder_dep
COPY src ./src
COPY Cargo.toml ./Cargo.toml
COPY asset ./asset
RUN --mount=type=cache,target=/var/cache/cargo cargo build --release --target aarch64-unknown-linux-musl

FROM alpine:latest
ARG UID="852"
ARG GID="852"
RUN addgroup -g "${GID}" proxy && adduser -u "${UID}" -G proxy -D -h /media-proxy-rs -s /bin/sh proxy
WORKDIR /media-proxy-rs
USER proxy
COPY asset ./asset
COPY --from=0 /app/target/aarch64-unknown-linux-musl/release/media-proxy-rsmedia-proxy-rs ./media-proxy-rs
EXPOSE 12766
CMD ["./media-proxy-rs"]
