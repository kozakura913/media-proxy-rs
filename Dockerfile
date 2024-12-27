FROM alpine:latest AS dav1d
COPY dav1d_build.sh /dav1d_build.sh
RUN --mount=type=cache,target=/dav1d_bin sh /dav1d_build.sh

FROM --platform=$BUILDPLATFORM rust:alpine AS build_base
ARG BUILDARCH
ARG TARGETARCH
ARG TARGETVARIANT
RUN apk add --no-cache clang musl-dev curl pkgconfig nasm mold git
ENV PKG_CONFIG_PATH=/dav1d/lib/pkgconfig
ENV LD_LIBRARY_PATH=/dav1d/lib
ENV CARGO_HOME=/var/cache/cargo
ENV SYSTEM_DEPS_LINK=static
COPY crossfiles /app/crossfiles
RUN --mount=type=cache,target=/musl sh /app/crossfiles/deps.sh
WORKDIR /app
COPY avif-decoder_dep ./avif-decoder_dep
COPY .gitmodules ./.gitmodules
COPY image-rs ./image-rs
COPY --from=0 /dav1d /dav1d
COPY src ./src
COPY Cargo.toml ./Cargo.toml
COPY asset ./asset
COPY examples ./examples
RUN --mount=type=cache,target=/var/cache/cargo --mount=type=cache,target=/app/target --mount=type=cache,target=/musl sh /app/crossfiles/build.sh

FROM alpine:latest
ARG UID="852"
ARG GID="852"
RUN addgroup -g "${GID}" proxy && adduser -u "${UID}" -G proxy -D -h /media-proxy-rs -s /bin/sh proxy
WORKDIR /media-proxy-rs
USER proxy
COPY asset ./asset
COPY --from=1 /app/media-proxy-rs ./media-proxy-rs
COPY --from=1 /app/healthcheck ./healthcheck
RUN sh -c "./media-proxy-rs&" && ./healthcheck 12887 http://127.0.0.1:12766/test.webp
HEALTHCHECK --interval=30s --timeout=3s CMD ./healthcheck 5555 http://127.0.0.1:12766/test.webp || exit 1
EXPOSE 12766
CMD ["./media-proxy-rs"]
