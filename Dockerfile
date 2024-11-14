FROM alpine:latest AS dav1d
COPY dav1d_build.sh /dav1d_build.sh
RUN --mount=type=cache,target=/dav1d_bin sh /dav1d_build.sh

FROM alpine:latest AS c_build_base
RUN apk add --no-cache clang musl-dev git cmake make

FROM c_build_base AS libwebp
RUN git clone -b "v1.4.0" --depth 1 "https://chromium.googlesource.com/webm/libwebp.git"
RUN mkdir /heif
RUN mkdir build_libwebp && cd build_libwebp
RUN cmake ../libwebp -DBUILD_SHARED_LIBS=false -DCMAKE_BUILD_TYPE=Release
RUN make -j $(nproc)
RUN cmake --install . --prefix /heif

FROM c_build_base AS libde265
RUN git clone -b "v1.0.15" --depth 1 "https://github.com/strukturag/libde265"
RUN mkdir build_libde265 && cd build_libde265
ENV CC=clang
RUN cmake ../libde265 -DBUILD_SHARED_LIBS=false -DENABLE_DECODER=false -D_GLIBCXX_USE_CXX11_ABI=1 -DCMAKE_CXX_STANDARD=20
RUN make -j $(nproc)
RUN cmake --install . --prefix /heif

FROM c_build_base AS heif
RUN git clone -b "v1.19.3" --depth 1 "https://github.com/strukturag/libheif"
COPY --from=libwebp /heif /heif
COPY --from=libde265 /heif /heif
RUN mkdir build_libheif && cd build_libheif
RUN cmake ../libheif -DWITH_OpenJPEG_DECODER=false -DWITH_OpenJPEG_ENCODER=false -DWITH_LIBSHARPYUV=true -DWITH_AOM_DECODER=false -DWITH_AOM_ENCODER=false -DWITH_X265=false -DWITH_OpenH264_DECODER=false -DBUILD_SHARED_LIBS=false \
 -DLIBDE265_INCLUDE_DIR=/heif/include -DLIBDE265_LIBRARY=/heif/lib/libde265.a -DLIBSHARPYUV_INCLUDE_DIR=/heif/include/webp -DLIBSHARPYUV_LIBRARY=/heif/lib/libsharpyuv.a -DCMAKE_INSTALL_PREFIX=/heif
RUN make -j $(nproc)
RUN cmake --install . --prefix /heif

FROM --platform=$BUILDPLATFORM rust AS bindgen
RUN cargo install bindgen-cli@0.70.1
RUN apt-get update && apt-get install -y clang git
COPY --from=heif /heif /heif
RUN rm -r /usr/include
COPY --from=heif /usr/include /usr/include
COPY crossfiles /app/crossfiles
ARG BUILDARCH
ARG TARGETARCH
ARG TARGETVARIANT
RUN bash -c "source /app/crossfiles/autoenv.sh && bindgen --formatter=prettyplease --output /heif/libheif.rs /heif/include/libheif/heif.h -- -I /heif/include --target=\${RUST_TARGET}"

FROM --platform=$BUILDPLATFORM rust:alpine AS build_base
ARG BUILDARCH
ARG TARGETARCH
ARG TARGETVARIANT
RUN apk add --no-cache clang musl-dev curl pkgconfig nasm git
ENV PKG_CONFIG_PATH=/dav1d/lib/pkgconfig
ENV LD_LIBRARY_PATH=/dav1d/lib
ENV CARGO_HOME=/var/cache/cargo
ENV SYSTEM_DEPS_LINK=static
COPY crossfiles /app/crossfiles
RUN --mount=type=cache,target=/musl sh /app/crossfiles/deps.sh
WORKDIR /app
COPY --from=heif /heif /heif
ENV LIBHEIF_LIBS_DIR=/heif/lib
ENV LIBHEIF_LINK_CXX=dynamic
COPY avif-decoder_dep ./avif-decoder_dep
COPY .gitmodules ./.gitmodules
COPY image-rs ./image-rs
COPY --from=dav1d /dav1d /dav1d
COPY src ./src
COPY Cargo.toml ./Cargo.toml
COPY asset ./asset
COPY examples ./examples
COPY libheif-rs-static ./libheif-rs-static
RUN rm ./libheif-rs-static/src/libheif.rs
#bindgenをターゲットアーキテクチャ用に差し替える
COPY --from=bindgen /heif/libheif.rs ./libheif-rs-static/src/libheif.rs
#bindgen --formatter=prettypleaseが変なの生成するから訂正
RUN sed -i "s/\*\// \*\//g" ./libheif-rs-static/src/libheif.rs
RUN --mount=type=cache,target=/var/cache/cargo --mount=type=cache,target=/app/target --mount=type=cache,target=/musl sh -c "cat ./libheif-rs-static/src/libheif.rs && sh /app/crossfiles/build.sh"

FROM alpine:latest
#FROM rust:alpine
ARG UID="852"
ARG GID="852"
RUN addgroup -g "${GID}" proxy && adduser -u "${UID}" -G proxy -D -h /media-proxy-rs -s /bin/sh proxy
WORKDIR /media-proxy-rs
USER proxy
COPY asset ./asset
#COPY --from=build_base /app/libs/* /lib
COPY --from=build_base /app/media-proxy-rs ./media-proxy-rs
COPY --from=build_base /app/healthcheck ./healthcheck
RUN sh -c "./media-proxy-rs&" && ./healthcheck 12887 http://127.0.0.1:12766/test.webp
HEALTHCHECK --interval=30s --timeout=3s CMD ./healthcheck 5555 http://127.0.0.1:12766/test.webp || exit 1
EXPOSE 12766
CMD ["./media-proxy-rs"]
#ldd ./media-proxy-rs
#CMD ["sh","-c","while true;do sleep 30;date;done"]
