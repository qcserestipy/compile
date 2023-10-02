#!/bin/bash

# Exit script if any command fails
set -xe

VERSION="2.2.5"
NAME="pmix"
INSTALL_DIR="/opt/shared/apps/${NAME}/$VERSION"
LMOD_DIR="/opt/shared/modules/${NAME}"
STORE_DIR="/opt/shared/store"


random_str=$(date +%s$RANDOM)
build_dir="build-$random_str"
mkdir $build_dir

# Download and unpack 
tar -xf ${STORE_DIR}/${NAME}-${VERSION}.tar.gz -C $build_dir/.

# Compile and install 
cd $build_dir/${NAME}-${VERSION}
  ./configure --prefix=$INSTALL_DIR 2>&1 | tee config.out
  make -j1 all 2>&1 | tee make.out
  make install 2>&1 | tee install.out
cd ..
cp -r ${NAME}-${VERSION}/* $INSTALL_DIR/.
cd ..
rm -rf $build_dir

chown -R pi: ${INSTALL_DIR}

# Create Lmod custom directory if not exists
sudo mkdir -p $LMOD_DIR

# Create the Lmod module file
echo "Creating Lmod module file for $NAME $VERSION"

tee $LMOD_DIR/$VERSION.lua <<EOL
help([[
This module loads ${NAME} $VERSION installed in $INSTALL_DIR.
]])

local version = "$VERSION"
local base    = "$INSTALL_DIR"

-- environment variables
setenv("PMIX_ROOT", base)
setenv("PMIX_PREFIX", base)
setenv("PMIX_BIN_PATH", pathJoin(base, "bin"))
setenv("PMIX_LIB_PATH", pathJoin(base, "lib"))

-- add binaries to path
prepend_path("PATH", pathJoin(base, "bin"))
prepend_path("MANPATH", pathJoin(base, "share/man"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib"))
prepend_path("LIBRARY_PATH", pathJoin(base, "lib"))
prepend_path("C_INCLUDE_PATH", pathJoin(base, "include"))

family("pmix")
EOL

echo "${NAME} $VERSION installation and module setup complete."
