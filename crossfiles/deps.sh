set -eu
source /app/crossfiles/${TARGETARCH}/env.sh
rustup target add ${RUST_TARGET}
if [ ${TARGETARCH} = amd64 ]; then
	apk add --no-cache nasm
fi
curl -sSL https://musl.cc/${MUSL_NAME}.tgz | tar -zxf - -C /
cd /dav1d
meson build -Dprefix=/app/dav1d -Denable_tools=false -Denable_examples=false -Ddefault_library=static --buildtype release --cross-file=/app/crossfiles/${TARGETARCH}/dav1d.meson 
ninja -C build && ninja -C build install
mkdir -p /${MUSL_NAME}/app/dav1d/
cp -r /app/dav1d/lib /${MUSL_NAME}/app/dav1d/lib
