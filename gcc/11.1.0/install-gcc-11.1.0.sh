#!/bin/bash

# Exit script if any command fails
set -xe

# Version to install
VERSION="11.1.0"
NAME="gcc"
INSTALL_DIR="/opt/shared/apps/$NAME/$VERSION"
LMOD_DIR="/opt/shared/modules/$NAME"
STORE_DIR="/opt/shared/store"
start=$(pwd)

random_str=$(date +%s$RANDOM)
build_dir="build-$random_str"
mkdir $build_dir
mkdir -p $INSTALL_DIR
# Download and unpack 
tar -xf ${STORE_DIR}/${NAME}-${VERSION}.tar.gz -C $build_dir/.


# Compile and install
cd $build_dir/${NAME}-${VERSION}
./configure -v --prefix=${INSTALL_DIR} \
               --enable-languages=c,c++,fortran \
	       --enable-shared \
	       --enable-linker-build-id \
	       --libexecdir=/usr/lib \
	       --without-included-gettext \
	       --enable-threads=posix \
	       --libdir=/usr/lib \
	       --enable-nls \
	       --enable-bootstrap \
	       --enable-clocale=gnu \
	       --enable-libstdcxx-debug \
	       --enable-libstdcxx-time=yes \
	       --with-default-libstdcxx-abi=new \
	       --enable-gnu-unique-object \
	       --disable-libitm \
	       --disable-libquadmath \
	       --disable-libquadmath-support \
	       --enable-plugin \
	       --with-system-zlib \
	       --enable-libphobos-checking=release \
	       --with-target-system-zlib=auto \
	       --enable-objc-gc=auto \
	       --enable-multiarch \
	       --disable-sjlj-exceptions \
	       --with-arch=armv6 \
	       --with-fpu=vfp \
	       --with-float=hard \
	       --disable-werror \
	       --enable-checking=release \
	       --build=arm-linux-gnueabihf \
	       --host=arm-linux-gnueabihf \
	       --target=arm-linux-gnueabihf 2>&1 | tee config.out

make -j$(nproc) 2>&1 | tee make.out
make install 2>&1 | tee install.out


cp -r * $INSTALL_DIR/.
cd $start

chown -R pi: $INSTALL_DIR

rm -rf $build_dir

# Create Lmod custom directory if not exists
sudo mkdir -p $LMOD_DIR

# Create the Lmod module file
echo "Creating Lmod module file for $NAME $VERSION"

tee $LMOD_DIR/${VERSION}.lua <<EOL
help([[
This module loads gcc $VERSION installed in $INSTALL_DIR.
]])

local version = "$VERSION"
local base    = "$INSTALL_DIR"

-- environment variables
setenv("CC", pathJoin(base,"bin/${NAME}-${VERSION}"))
setenv("CXX", pathJoin(base,"bin/g++-${VERSION}"))
setenv("FC", pathJoin(base,"bin/gfortran-${VERSION}"))

-- add binaries to path
prepend_path("PATH", pathJoin(base, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib64"))
family("gcc")
-- add any other gcc specific variables here
EOL

echo "gcc $VERSION installation and module setup complete."
