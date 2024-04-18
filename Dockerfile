FROM ghcr.io/kozakura913/static-dav1d-lib:master

FROM --platform=$BUILDPLATFORM rust:alpine
ARG BUILDARCH
ARG TARGETARCH
ARG TARGETVARIANT
RUN apk add --no-cache clang musl-dev curl pkgconfig nasm mold
ENV PKG_CONFIG_PATH=/dav1d/lib/pkgconfig
ENV LD_LIBRARY_PATH=/dav1d/lib
ENV CARGO_HOME=/var/cache/cargo
ENV SYSTEM_DEPS_LINK=static
COPY --from=0 /dav1d /dav1d
COPY crossfiles /app/crossfiles
RUN sh /app/crossfiles/deps.sh
WORKDIR /app
COPY avif-decoder_dep ./avif-decoder_dep
COPY src ./src
COPY Cargo.toml ./Cargo.toml
COPY asset ./asset
RUN --mount=type=cache,target=/var/cache/cargo --mount=type=cache,target=/app/target sh /app/crossfiles/build.sh

FROM alpine:latest
ARG UID="852"
ARG GID="852"
RUN addgroup -g "${GID}" proxy && adduser -u "${UID}" -G proxy -D -h /media-proxy-rs -s /bin/sh proxy
WORKDIR /media-proxy-rs
USER proxy
COPY asset ./asset
COPY --from=1 /app/media-proxy-rs ./media-proxy-rs
EXPOSE 12766
CMD ["./media-proxy-rs"]
