FROM --platform=$BUILDPLATFORM rust:alpine
ARG BUILDARCH
ARG TARGETARCH
RUN apk add --no-cache clang musl-dev curl meson ninja pkgconfig git
COPY crossfiles /app/crossfiles
RUN sh /app/crossfiles/arm64.sh
WORKDIR /app
COPY avif-decoder_dep ./avif-decoder_dep
COPY src ./src
COPY Cargo.toml ./Cargo.toml
COPY asset ./asset
RUN --mount=type=cache,target=/var/cache/cargo cargo build --release --target ${RUST_TARGET}

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
