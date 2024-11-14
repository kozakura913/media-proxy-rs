set -eu
source /app/crossfiles/autoenv.sh
rustup target add ${RUST_TARGET}
if [ -d "/musl/${MUSL_NAME}" ]; then
	:
else
	curl -sSL https://musl.cc/${MUSL_NAME}.tgz | tar -zxf - -C /musl
fi
mkdir -p /musl/${MUSL_NAME}/dav1d/
