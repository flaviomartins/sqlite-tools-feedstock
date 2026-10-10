#!/bin/bash

set -euxo pipefail

# Prevent running ldconfig when cross-compiling.
if [[ "${BUILD}" != "${HOST}" ]]; then
  echo "#!/usr/bin/env bash" > ldconfig
  chmod +x ldconfig
  export PATH=${PWD}:$PATH
fi

export OPTIONS="${OPTIONS:-}"

if [[ $target_platform =~ linux.* ]]; then
    export CPPFLAGS="${CPPFLAGS} -DHAVE_PREAD64 -DHAVE_PWRITE64"
fi

if [[ "$target_platform" == "linux-ppc64le" ]]; then
    export PPC64LE="--build=ppc64le-linux"
else
    export PPC64LE=""
fi

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include ${OPTIONS}"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

./configure --prefix=${PREFIX} \
            --build=${BUILD} \
            --host=${HOST} \
            --enable-threadsafe \
            --enable-load-extension \
            --disable-static \
            --with-tclsh="${BUILD_PREFIX}/bin/tclsh" \
            ${PPC64LE}

make -j${CPU_COUNT} sqldiff
install -m755 sqldiff "${PREFIX}/bin/sqldiff"

make -j${CPU_COUNT} sqlite3_rsync
install -m755 sqlite3_rsync "${PREFIX}/bin/sqlite3_rsync"
