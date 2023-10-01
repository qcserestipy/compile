#!/bin/bash

# Exit script if any command fails
set -xe

# Version to install
VERSION="11.4.0"
NAME="gcc"
INSTALL_DIR="/opt/software/$NAME/$VERSION"
LMOD_DIR="/opt/ohpc/pub/modulefiles/$NAME"
STORE_DIR="/opt/store"


random_str=$(date +%s$RANDOM)
build_dir="build-$random_str"
mkdir $build_dir
mkdir $build_dir/${NAME}-${VERSION}

# Download and unpack 
tar -xf ${STORE_DIR}/${NAME}-${VERSION}.tar.gz -C $build_dir/${NAME}-${VERSION}

# Compile and install
cd $build_dir/${NAME}-${VERSION}/gcc-releases-${NAME}-${VERSION}
  ./configure -v --build=x86_64-linux-gnu \
                 --host=x86_64-linux-gnu \
                 --target=x86_64-linux-gnu \
                 --prefix=${INSTALL_DIR} \
                 --enable-checking=release \
                 --enable-languages=c,c++,fortran \
                 --disable-multilib \
                 --program-suffix=-11.1  2>&1 | tee config.out
  make -j$(nproc) 2>&1 | tee make.out
  make install-strip 2>&1 | tee install.out
cd ..
mv ${NAME}-${VERSION}/* $INSTALL_DIR/.

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
