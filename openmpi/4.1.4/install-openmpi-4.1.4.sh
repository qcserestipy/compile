#!/bin/bash

# Exit script if any command fails
set -xe

# Version of OpenMPI to install
OPENMPI_VERSION="4.1.4"
INSTALL_DIR="/opt/shared/apps/openmpi/$OPENMPI_VERSION"
LMOD_DIR="/opt/shared/modules/openmpi"
STORE_DIR="/opt/shared/store"

module load pmix/4.1.1

random_str=$(date +%s$RANDOM)
build_dir="build-$random_str"
mkdir $build_dir

# Download and unpack OpenMPI
tar -xf ${STORE_DIR}/openmpi-$OPENMPI_VERSION.tar.gz -C $build_dir/.

# Compile and install OpenMPI
cd $build_dir/openmpi-$OPENMPI_VERSION
  ./configure --prefix=$INSTALL_DIR \
	      --host=arm-linux-gnueabi \
	      --build=$(build-aux/config.guess) \
	      --with-pmix=$PMIX_ROOT 2>&1 | tee config.out
  make -j$(nproc) all 2>&1 | tee make.out
  sudo make install 2>&1 | tee install.out
cd ..
mv openmpi-$OPENMPI_VERSION/* $INSTALL_DIR/.

rm -rf $build_dir

# Create Lmod custom directory if not exists
sudo mkdir -p $LMOD_DIR

# Create the Lmod module file
echo "Creating Lmod module file for OpenMPI $OPENMPI_VERSION"

tee $LMOD_DIR/$OPENMPI_VERSION.lua <<EOL
help([[
This module loads OpenMPI $OPENMPI_VERSION installed in $INSTALL_DIR.
]])

local version = "$OPENMPI_VERSION"
local base    = "$INSTALL_DIR"

-- environment variables
setenv("MPI_HOME", base)

-- add binaries to path
prepend_path("PATH", pathJoin(base, "bin"))
prepend_path("MANPATH", pathJoin(base, "share/man"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base, "lib"))
family("openmpi")
-- add any other OpenMPI specific variables here
EOL

echo "OpenMPI $OPENMPI_VERSION installation and module setup complete."
