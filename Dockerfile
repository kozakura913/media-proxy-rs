FROM alpine:latest AS dav1d
RUN apk add --no-cache clang musl-dev meson ninja pkgconfig nasm git
RUN git clone --branch 1.3.0 --depth 1 https://code.videolan.org/videolan/dav1d.git /dav1d_src
WORKDIR /dav1d_src
RUN meson build -Dprefix=/dav1d -Denable_tools=false -Denable_examples=false -Ddefault_library=static --buildtype release
RUN ninja -C build
RUN ninja -C build install
RUN rm -r /dav1d_src

FROM --platform=$BUILDPLATFORM rust:alpine AS build_base
ARG BUILDARCH
ARG TARGETARCH
ARG TARGETVARIANT
RUN apk add --no-cache clang musl-dev curl pkgconfig nasm mold
ENV PKG_CONFIG_PATH=/dav1d/lib/pkgconfig
ENV LD_LIBRARY_PATH=/dav1d/lib
ENV CARGO_HOME=/var/cache/cargo
ENV SYSTEM_DEPS_LINK=static
COPY crossfiles /app/crossfiles
RUN sh /app/crossfiles/deps.sh

FROM --platform=$BUILDPLATFORM build_base AS build
COPY --from=DAV1D /dav1d /dav1d
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
COPY --from=build /app/media-proxy-rs ./media-proxy-rs
EXPOSE 12766
CMD ["./media-proxy-rs"]
