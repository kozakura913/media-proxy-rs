FROM alpine:latest AS c_build_env
RUN apk add --no-cache make clang musl-dev meson ninja pkgconfig nasm git cmake

FROM c_build_env AS dav1d
RUN git clone --branch 1.3.0 --depth 1 https://code.videolan.org/videolan/dav1d.git /dav1d_src
RUN cd /dav1d_src && meson build -Dprefix=/dav1d -Denable_tools=false -Denable_examples=false -Ddefault_library=static --buildtype release
RUN cd /dav1d_src && ninja -C build
RUN cd /dav1d_src && ninja -C build install

FROM c_build_env AS libwebp
RUN git clone -b "v1.4.0" --depth 1 "https://chromium.googlesource.com/webm/libwebp.git"
RUN mkdir /heif
RUN mkdir build_libwebp && cd build_libwebp
RUN cmake ../libwebp -DBUILD_SHARED_LIBS=false -DCMAKE_BUILD_TYPE=Release
RUN make -j $(nproc)
RUN cmake --install . --prefix /heif

FROM c_build_env AS lcms2
RUN git clone -b lcms2.16 --depth 1 https://github.com/mm2/Little-CMS.git /lcms2_src
ENV CONFIGURE_FLAGS="--enable-static --prefix=/lcms2"
RUN cd /lcms2_src && ./configure
RUN cd /lcms2_src && make
RUN cd /lcms2_src && make DESTDIR=/lcms2 install

FROM --platform=$BUILDPLATFORM alpine:latest AS cross_build_base
ARG BUILDARCH
ARG TARGETARCH
ARG TARGETVARIANT
RUN apk add --no-cache clang musl-dev curl pkgconfig nasm git cmake make
COPY crossfiles /app/crossfiles
RUN sh /app/crossfiles/toolchain.sh
RUN sh /app/crossfiles/deps.sh

FROM cross_build_base AS libde265
RUN git clone -b "v1.0.15" --depth 1 "https://github.com/strukturag/libde265"
RUN mkdir build_libde265 && cd build_libde265
RUN sh -c "source /app/crossfiles/autoenv.sh && cmake ../libde265 -DBUILD_SHARED_LIBS=false -DENABLE_DECODER=false -DCMAKE_TOOLCHAIN_FILE=/app/crossfiles/toolchain.cmake"
RUN make -j $(nproc)
RUN cmake --install . --prefix /heif

FROM cross_build_base AS heif
RUN git clone -b "v1.19.3" --depth 1 "https://github.com/strukturag/libheif"
COPY --from=libwebp /heif /heif
COPY --from=libde265 /heif /heif
RUN mkdir build_libheif && cd build_libheif
RUN sh -c "source /app/crossfiles/autoenv.sh && \
 cmake ../libheif -DWITH_OpenJPEG_DECODER=false -DWITH_OpenJPEG_ENCODER=false -DWITH_LIBSHARPYUV=true -DWITH_AOM_DECODER=false -DWITH_AOM_ENCODER=false -DWITH_X265=false -DWITH_OpenH264_DECODER=false -DBUILD_SHARED_LIBS=false \
 -DLIBDE265_INCLUDE_DIR=/heif/include -DLIBDE265_LIBRARY=/heif/lib/libde265.a -DLIBSHARPYUV_INCLUDE_DIR=/heif/include/webp -DLIBSHARPYUV_LIBRARY=/heif/lib/libsharpyuv.a -DCMAKE_INSTALL_PREFIX=/heif -DCMAKE_TOOLCHAIN_FILE=/app/crossfiles/toolchain.cmake"
RUN make -j $(nproc)
RUN cmake --install . --prefix /heif

FROM --platform=$BUILDPLATFORM rust AS build_app
ARG BUILDARCH
ARG TARGETARCH
ARG TARGETVARIANT
#RUN apk add --no-cache clang musl-dev curl pkgconfig nasm mold git
RUN apt-get update && apt-get install -y clang musl-dev pkg-config nasm mold git
ENV CARGO_HOME=/var/cache/cargo
ENV SYSTEM_DEPS_LINK=static
COPY crossfiles /app/crossfiles
RUN bash /app/crossfiles/deps.sh
WORKDIR /app
COPY avif-decoder_dep ./avif-decoder_dep
COPY --from=dav1d /dav1d /dav1d
COPY --from=lcms2 /lcms2 /lcms2
COPY --from=heif /heif /heif
RUN cp -r /lcms2/usr/local/lib/* /dav1d/lib
ENV LD_LIBRARY_PATH=/dav1d/lib
COPY --from=heif /heif/lib/pkgconfig /pkgconfig
COPY --from=dav1d /dav1d/lib/pkgconfig /pkgconfig
COPY --from=heif /heif /heif
ENV PKG_CONFIG_PATH=/pkgconfig
COPY src ./src
COPY Cargo.toml ./Cargo.toml
COPY asset ./asset
COPY examples ./examples
RUN --mount=type=cache,target=/var/cache/cargo --mount=type=cache,target=/app/target bash /app/crossfiles/build.sh

FROM alpine:latest
ARG UID="852"
ARG GID="852"
RUN addgroup -g "${GID}" proxy && adduser -u "${UID}" -G proxy -D -h /media-proxy-rs -s /bin/sh proxy
WORKDIR /media-proxy-rs
USER proxy
COPY --from=build_app /app/media-proxy-rs ./media-proxy-rs
COPY --from=build_app /app/healthcheck ./healthcheck
RUN sh -c "./media-proxy-rs&" && ./healthcheck 12887 http://127.0.0.1:12766/test.webp
HEALTHCHECK --interval=30s --timeout=3s CMD ./healthcheck 5555 http://127.0.0.1:12766/test.webp || exit 1
EXPOSE 12766
CMD ["./media-proxy-rs"]
