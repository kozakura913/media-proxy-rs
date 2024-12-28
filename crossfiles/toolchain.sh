set -eu
if [ -f "/app/crossfiles/${TARGETARCH}.sh" ]; then
	source /app/crossfiles/${TARGETARCH}.sh
else
	source /app/crossfiles/${TARGETARCH}/${TARGETVARIANT}.sh
fi
echo "SET(CMAKE_SYSTEM_NAME Linux)" > /app/crossfiles/toolchain.cmake
echo "SET(CMAKE_C_COMPILER ${PKG_CONFIG_SYSROOT_DIR}/bin/${CC})" >> /app/crossfiles/toolchain.cmake
echo "SET(CMAKE_CXX_COMPILER ${PKG_CONFIG_SYSROOT_DIR}/bin/${CXX})" >> /app/crossfiles/toolchain.cmake
echo "SET(CMAKE_LINKER ${PKG_CONFIG_SYSROOT_DIR}/bin/${CC})" >> /app/crossfiles/toolchain.cmake
echo "SET(CMAKE_FIND_ROOT_PATH ${PKG_CONFIG_SYSROOT_DIR})" >> /app/crossfiles/toolchain.cmake
