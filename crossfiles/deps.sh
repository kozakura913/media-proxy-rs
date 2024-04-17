set -eu
if [ ${TARGETARCH} = ${BUILDARCH} ]; then
	exit 0
fi
source /app/crossfiles/${TARGETARCH}.sh
rustup target add ${RUST_TARGET}
curl -sSL https://musl.cc/${MUSL_NAME}.tgz | tar -zxf - -C /
cd /dav1d
cat <<EOF > crossfile.meson
[binaries]
c = '${CC}'
cpp = '${CXX}'
ar = '${AR}'
[host_machine]
system = 'linux'
cpu_family = '${CPU_FAMILY}'
cpu = '${TARGET_CPU}'
endian = 'little'
EOF
meson build -Dprefix=/app/dav1d -Denable_tools=false -Denable_examples=false -Ddefault_library=static --buildtype release --cross-file=/dav1d/crossfile.meson 
ninja -C build && ninja -C build install
mkdir -p /${MUSL_NAME}/app/dav1d/
cp -r /app/dav1d/lib /${MUSL_NAME}/app/dav1d/lib
